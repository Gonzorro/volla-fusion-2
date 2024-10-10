using Fusion;
using UnityEngine;
using DG.Tweening;

public class Projectile : NetworkBehaviour
{
    [System.Serializable]
    public class ProjectileParticleHandler
    {
        public GameObject ParentGameObject;
        public ParticleSystem ParticleSystem;
        [HideInInspector] public Vector3 OriginalPosition;
        [HideInInspector] public Quaternion OriginalRotation;
    }

    [System.Serializable]
    public struct ProjectileComponents
    {
        public GameObject ParentGesture;
        public GameObject GestureParticle;
        public Collider collider;
        public ProjectileParticleHandler MuzzleTuple;
        public ProjectileParticleHandler CollisionTuple;
    }

    [Header("Channels")]
    [SerializeField] private ProjectileChannel projectileChannel;
    [SerializeField] private HealthChannel healthChannel;

    [Header("References")]
    [SerializeField] private GameObject projectilePhysics;
    [SerializeField] private ProjectileCollisionEvent physicsCollisionEvent;

    [Space, SerializeField] private ProjectileComponents PunchGestureRefs;
    [SerializeField] private ProjectileComponents UpperCutGestureRefs;

    [Networked, OnChangedRender(nameof(OnToggleActiveProjectile))] private NetworkBool IsProjectileActive { get; set; }
    [Networked, OnChangedRender(nameof(OnProjectileCollided))] private NetworkBool IsProjectileNetworkCollided { get; set; }

    [Networked] int CurrentComponentIndex { get; set; }
    private ProjectileComponents currentComponents;

    private float projectileLifeTime;
    private bool projectileDestroyed;

    private HandEnum projectileHand;
    private PlayerClassEnum projectileClass;

    private int enemyLayer;
    bool isRedTeam;

    private void Awake()
    {
        physicsCollisionEvent.OnCollisionEnterEvent.AddListener(OnPhysicsCollisionEnter);
        physicsCollisionEvent.OnTriggerEnterEvent.AddListener(OnTriggerEnterEvent);
    }

    public override void Spawned()
    {
        InitializeProjectileComponents(PunchGestureRefs);
        InitializeProjectileComponents(UpperCutGestureRefs);
    }

    private void Start()
    {
        InitializeProjectileComponents(PunchGestureRefs);
        InitializeProjectileComponents(UpperCutGestureRefs);
    }

    private void OnDestroy() => physicsCollisionEvent.OnCollisionEnterEvent.RemoveListener(OnPhysicsCollisionEnter);

    public void InitializeProjectile(PlayerTeamEnum playerTeam, float lifeTime, HandEnum hand, PlayerClassEnum playerClass)
    {
        projectileClass = playerClass;
        projectileLifeTime = lifeTime;
        projectileHand = hand;
        isRedTeam = playerTeam == PlayerTeamEnum.RedTeam;
        string enemyLayerName = playerTeam == PlayerTeamEnum.RedTeam ? "BlueTeam" : "RedTeam";
        enemyLayer = LayerMask.NameToLayer(enemyLayerName);

        if (projectileLifeTime <= 0) Debug.LogError("Lifetime of Projectiles is 0 or less, won't show up!");
    }

    private void InitializeProjectileComponents(ProjectileComponents pair)
    {
        pair.collider.enabled = false;
        pair.ParentGesture.SetActive(false);
        pair.GestureParticle.SetActive(true);
        pair.MuzzleTuple.ParentGameObject.SetActive(false);
        pair.CollisionTuple.ParentGameObject.SetActive(false);

        pair.MuzzleTuple.OriginalPosition = pair.MuzzleTuple.ParticleSystem.transform.localPosition;
        pair.MuzzleTuple.OriginalRotation = pair.MuzzleTuple.ParticleSystem.transform.rotation;
        pair.CollisionTuple.OriginalPosition = pair.CollisionTuple.ParticleSystem.transform.localPosition;
        pair.CollisionTuple.OriginalRotation = pair.CollisionTuple.ParticleSystem.transform.rotation;
    }

    public void ActivateProjectile(ProjectileType projectileType)
    {
        projectileDestroyed = false;
        DOVirtual.DelayedCall(projectileLifeTime, TryDeactivateProjectile);

        int index = (int)projectileType;
        CurrentComponentIndex = index;

        if (Object.Runner.GameMode == GameMode.Single || Object.HasStateAuthority)
        {
            currentComponents = GetProjectileComponents(index);
            IsProjectileActive = true;

            if (Object.Runner.GameMode == GameMode.Single)
            {
                // Manually trigger the callback in Single mode
                OnToggleActiveProjectile();
            }
        }
    }

    private ProjectileComponents GetProjectileComponents(int projectileType)
    {
        switch (projectileType)
        {
            case 0:
                return PunchGestureRefs;
            case 1:
                return UpperCutGestureRefs;
            default:
                Debug.LogError("Invalid particle index: " + projectileType);
                return default;
        }
    }

    public void OnToggleActiveProjectile()
    {
        currentComponents = GetProjectileComponents(CurrentComponentIndex);

        if (IsProjectileActive)
        {
            currentComponents.GestureParticle.transform.localScale = Vector3.one;
            currentComponents.ParentGesture.SetActive(true);
            projectilePhysics.SetActive(true);
            currentComponents.collider.enabled = true;
        }
        else
        {
            IsProjectileNetworkCollided = false;
            currentComponents.collider.enabled = false;
            currentComponents.GestureParticle.transform.DOScale(0, 0.225f).SetEase(Ease.OutQuart).OnComplete(() => ReturnProjectileToPool());
        }
    }

    private void TryDeactivateProjectile()
    {
        if (projectileDestroyed) return;
        projectileDestroyed = true;
        IsProjectileActive = false;

        if (Object.Runner.GameMode == GameMode.Single)
        {
            // Manually trigger the callback in Single mode
            OnToggleActiveProjectile();
        }
    }

    private void ReturnProjectileToPool()
    {
        projectileDestroyed = false;
        projectilePhysics.SetActive(false);
        currentComponents.ParentGesture.SetActive(false);

        if (Object.HasStateAuthority || Object.Runner.GameMode == GameMode.Single)
            projectileChannel.ReturnProjectileToPool(projectilePhysics, projectileHand, projectileClass);
    }

    private void OnPhysicsCollisionEnter(Collision collision)
    {
        if (Object.HasStateAuthority || Object.Runner.GameMode == GameMode.Single)
        {
            IsProjectileNetworkCollided = true;

            if (Object.Runner.GameMode == GameMode.Single)
            {
                // Manually trigger the callback in Single mode
                OnProjectileCollided();
            }
        }
        else
        {
            HandleParticlesDettachment(currentComponents.CollisionTuple);
        }

        TryDeactivateProjectile();
    }

    private void OnTriggerEnterEvent(Collider collider)
    {
        if (!Object.HasStateAuthority || collider.gameObject.layer != enemyLayer) return;

        if (isRedTeam) healthChannel.OnDamageBlueTeam(10);
        else healthChannel.OnDamageRedTeam(10);

        IsProjectileNetworkCollided = true;

        if (Object.Runner.GameMode == GameMode.Single)
        {
            // Manually trigger the callback in Single mode
            OnProjectileCollided();
        }

        TryDeactivateProjectile();
    }

    public void OnProjectileCollided() => HandleNetworkCollisionParticle();

    private void HandleNetworkCollisionParticle()
    {
        if (!IsProjectileNetworkCollided) return;
        HandleParticlesDettachment(currentComponents.CollisionTuple);
    }

    private void HandleParticlesDettachment(ProjectileParticleHandler particleHandler)
    {
        var particleSystem = particleHandler.ParticleSystem;
        particleSystem.transform.parent = null;
        particleSystem.Play(true);

        DOVirtual.DelayedCall(5f, () => HandleParticlesAttachment(particleHandler));
    }

    private void HandleParticlesAttachment(ProjectileParticleHandler particleHandler)
    {
        particleHandler.ParticleSystem.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
        particleHandler.ParticleSystem.transform.SetParent(particleHandler.ParentGameObject.transform);
        particleHandler.ParticleSystem.transform.SetLocalPositionAndRotation(particleHandler.OriginalPosition, particleHandler.OriginalRotation);
    }
}
