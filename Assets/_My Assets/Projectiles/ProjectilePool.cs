using Fusion;
using System;
using UnityEngine;
using DG.Tweening;
using System.Threading.Tasks;
using System.Collections.Generic;

public class ProjectilePool : MonoBehaviour
{
    [Header("Parameters")]
    [SerializeField] private int initialSize = 8;
    [SerializeField] private float projectileLifeTime;
    [SerializeField] private bool isSingleClassProjectilePool;

    [Header("Channels")]
    [SerializeField] private PlatformModeChannel platformChannel;
    [SerializeField] private NetworkRunnerChannel runnerChannel;
    [SerializeField] private PlayerInfoChannel playerInfoChannel;
    [SerializeField] private ProjectileChannel projectileChannel;

    [Header("Class Projectile Prefabs")]
    [SerializeField] private ClassProjectiles guardClassProjectiles;
    [SerializeField] private ClassProjectiles strikerClassProjectiles;
    [SerializeField] private ClassProjectiles wingClassProjectiles;

    [Serializable]
    public class ClassProjectiles
    {
        public PlayerClassEnum classProjectiles;
        public GameObject primaryHandProjectilePrefab;
        public GameObject secondaryHandProjectilePrefab;

        [NonSerialized] public Queue<GameObject> primaryProjectilePool = new();
        [NonSerialized] public Queue<GameObject> secondaryProjectilePool = new();
        [NonSerialized] public Dictionary<GameObject, (Projectile, Rigidbody)> primaryProjectileComponentsCache = new();
        [NonSerialized] public Dictionary<GameObject, (Projectile, Rigidbody)> secondaryProjectileComponentsCache = new();
    }

    private bool isRightHanded;

    private async void Start()
    {
        playerInfoChannel.SetPlayerStrongHand(PlayerStrongHandEnum.RightHand);
        if (platformChannel.GetPlatformMode() == PlatformModeEnum.WindowsPlatform) return;

        isRightHanded = playerInfoChannel.GetPlayerStrongHand() == PlayerStrongHandEnum.RightHand;

        await Task.Delay(5000);

        InitializePoolSystem();
        SubscribeToChannelEvents();
    }

    private void OnDestroy() => UnsubscribeFromChannelEvents();

    private void InitializePoolSystem()
    {
        if (isSingleClassProjectilePool)
        {
            PlayerClassEnum playerClass = playerInfoChannel.GetPlayerClass();
            ClassProjectiles selectedClassProjectiles = GetClassProjectilesByType(playerClass);
            CreateAndCacheClassProjectiles(selectedClassProjectiles);
        }
        else
        {
            CreateAndCacheClassProjectiles(guardClassProjectiles);
            CreateAndCacheClassProjectiles(strikerClassProjectiles);
            CreateAndCacheClassProjectiles(wingClassProjectiles);
        }
    }

    private ClassProjectiles GetClassProjectilesByType(PlayerClassEnum playerClass)
    {
        return playerClass switch
        {
            PlayerClassEnum.Guard => guardClassProjectiles,
            PlayerClassEnum.Striker => strikerClassProjectiles,
            PlayerClassEnum.Wing => wingClassProjectiles,
            _ => throw new ArgumentOutOfRangeException(nameof(playerClass), $"Unhandled class type: {playerClass}"),
        };
    }

    private void CreateAndCacheClassProjectiles(ClassProjectiles classProjectiles)
    {
        CreateAndCacheForType(classProjectiles, classProjectiles.primaryHandProjectilePrefab, true);
        CreateAndCacheForType(classProjectiles, classProjectiles.secondaryHandProjectilePrefab, false);
    }

    private void CreateAndCacheForType(ClassProjectiles classProjectiles, GameObject prefab, bool isPrimary)
    {
        if (runnerChannel.NetworkRunner == null || runnerChannel.NetworkRunner.State != NetworkRunner.States.Running)
        {
            Debug.LogError("NetworkRunner is not initialized or not in a running state.");
            return;
        }

        var playerTeam = playerInfoChannel.GetPlayerTeam();
        var strongHand = playerInfoChannel.GetPlayerStrongHand();

        for (int i = 0; i < initialSize; i++)
        {
            var spawnedProjectile = FindObjectOfType<NetworkRunner>().Spawn(prefab).gameObject;
            var physicsObject = spawnedProjectile.transform.GetChild(0);

            if (spawnedProjectile.TryGetComponent(out Projectile projectileScript) && physicsObject.TryGetComponent(out Rigidbody rb))
            {
                bool usePrimaryPool = (strongHand == PlayerStrongHandEnum.RightHand && isPrimary) || (strongHand == PlayerStrongHandEnum.LeftHand && !isPrimary);

                var targetCache = usePrimaryPool ? classProjectiles.primaryProjectileComponentsCache : classProjectiles.secondaryProjectileComponentsCache;
                var targetPool = usePrimaryPool ? classProjectiles.primaryProjectilePool : classProjectiles.secondaryProjectilePool;

                targetCache.Add(physicsObject.gameObject, (projectileScript, rb));
                targetPool.Enqueue(physicsObject.gameObject);
                projectileScript.InitializeProjectile(playerTeam, projectileLifeTime, isPrimary ? HandEnum.RightHand : HandEnum.LeftHand, classProjectiles.classProjectiles);
            }
            else
            {
                Debug.LogError("Projectile doesn't have both Components");
            }
        }
        //    Debug.LogError($"PPool: {classProjectiles.primaryProjectilePool.Count}  SPool: {classProjectiles.secondaryProjectilePool.Count}  PCache: {classProjectiles.primaryProjectileComponentsCache.Count}  SCache: {classProjectiles.secondaryProjectileComponentsCache.Count}");
    }


    public void LaunchPooledProjectile(Transform launchPosition, ProjectileType projectileType, HandEnum hand)
    {
        PlayerClassEnum playerClass = playerInfoChannel.GetPlayerClass();
        ClassProjectiles classProjectiles = GetClassProjectilesByType(playerClass);

        Queue<GameObject> pool = hand == HandEnum.RightHand ? classProjectiles.primaryProjectilePool : classProjectiles.secondaryProjectilePool;
        Dictionary<GameObject, (Projectile, Rigidbody)> cache = hand == HandEnum.RightHand ? classProjectiles.primaryProjectileComponentsCache : classProjectiles.secondaryProjectileComponentsCache;

        var projectileObject = pool.Dequeue();
        if (!cache.TryGetValue(projectileObject, out var components))
        {
            Debug.LogError("Projectile not found in cache");
            return;
        }

        var (projectileScript, rb) = components;
        rb.velocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;

        bool isLaunchingWithStrongHand = (hand == HandEnum.RightHand && playerInfoChannel.GetPlayerStrongHand() == PlayerStrongHandEnum.RightHand) || (hand == HandEnum.LeftHand && playerInfoChannel.GetPlayerStrongHand() == PlayerStrongHandEnum.LeftHand);

        if (isLaunchingWithStrongHand)
            PrimaryHandProjectileLaunch(launchPosition, projectileType, projectileObject.transform, rb);
        else
            SecondaryHandProjectileLaunch(launchPosition, projectileType, projectileObject.transform, rb);
        Debug.LogError("Ativating from pool");
        projectileScript.ActivateProjectile(projectileType);
    }

    private void PrimaryHandProjectileLaunch(Transform launchPosition, ProjectileType projectileType, Transform projectileTransform, Rigidbody rb)
    {
        switch (projectileType)
        {
            case ProjectileType.Punch:
                rb.isKinematic = false;
                projectileTransform.SetPositionAndRotation(launchPosition.position, launchPosition.rotation);
                rb.velocity = launchPosition.TransformDirection(Vector3.forward * 15);
                break;

            case ProjectileType.UpperCut:
                rb.isKinematic = false;
                projectileTransform.SetPositionAndRotation(launchPosition.position, Quaternion.Euler(0, projectileTransform.eulerAngles.y, 0));
                var handForward = launchPosition.forward;
                var horizontalForward = new Vector3(handForward.x, 0, handForward.z).normalized;
                rb.velocity = horizontalForward * 15;
                break;

            case ProjectileType.Hook:
                rb.isKinematic = false;
                projectileTransform.SetPositionAndRotation(launchPosition.position, launchPosition.rotation);
                projectileTransform.forward = launchPosition.forward;
                rb.velocity = launchPosition.TransformDirection(Vector3.forward * 15);
                break;
        }
    }

    private void SecondaryHandProjectileLaunch(Transform launchPosition, ProjectileType projectileType, Transform projectileTransform, Rigidbody rb)
    {
        switch (projectileType)
        {
            case ProjectileType.Punch:
                rb.isKinematic = false;
                projectileTransform.SetPositionAndRotation(launchPosition.position, launchPosition.rotation);
                rb.velocity = launchPosition.TransformDirection(Vector3.forward * 15);
                break;

            case ProjectileType.UpperCut:
                rb.isKinematic = true;
                Vector3 startSpawnPosition = launchPosition.position + launchPosition.forward * 1.5f;
                startSpawnPosition.y = -0.55f;
                projectileTransform.SetPositionAndRotation(startSpawnPosition, Quaternion.Euler(0, launchPosition.rotation.eulerAngles.y, 0));
                projectileTransform.DOMoveY(1f, 0.25f).SetRelative().SetEase(Ease.OutQuad);
                break;

            case ProjectileType.Hook:
                rb.isKinematic = false;
                projectileTransform.SetPositionAndRotation(launchPosition.position, launchPosition.rotation);
                projectileTransform.forward = launchPosition.forward;
                rb.velocity = launchPosition.TransformDirection(Vector3.forward * 15);
                break;
        }
    }

    public void ReturnProjectileToPool(GameObject projectileObject, HandEnum hand, PlayerClassEnum playerClass)
    {
        ClassProjectiles classProjectiles = GetClassProjectilesByType(playerClass);
        bool isPrimary = hand == HandEnum.RightHand ? isRightHanded : !isRightHanded;

        Queue<GameObject> pool = isPrimary ? classProjectiles.primaryProjectilePool : classProjectiles.secondaryProjectilePool;
        Dictionary<GameObject, (Projectile, Rigidbody)> cache = isPrimary ?
            classProjectiles.primaryProjectileComponentsCache : classProjectiles.secondaryProjectileComponentsCache;

        if (cache.ContainsKey(projectileObject))
        {
            var (projectileScript, rb) = cache[projectileObject];
            rb.velocity = Vector3.zero;
            rb.angularVelocity = Vector3.zero;
            projectileObject.SetActive(false);

            pool.Enqueue(projectileObject);
        }
        else
        {
            Debug.LogError("Projectile to return not found in cache");
        }
    }

    private void SubscribeToChannelEvents()
    {
        projectileChannel.OnLaunchProjectile += LaunchPooledProjectile;
        projectileChannel.OnReturnProjectileToPool += ReturnProjectileToPool;
    }

    private void UnsubscribeFromChannelEvents()
    {
        projectileChannel.OnLaunchProjectile -= LaunchPooledProjectile;
        projectileChannel.OnReturnProjectileToPool -= ReturnProjectileToPool;
    }
}
