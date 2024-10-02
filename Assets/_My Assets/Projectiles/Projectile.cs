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
    // [SerializeField] private NetworkRigidbody networkRb;
    [SerializeField] private ProjectileCollisionEvent physicsCollisionEvent;

    [Space, SerializeField] private ProjectileComponents PunchGestureRefs;
    [SerializeField] private ProjectileComponents UpperCutGestureRefs;

    [Networked, OnChangedRender(nameof(OnToggleActiveProjectile))] private NetworkBool IsProjectileActive { get; set; }
    private bool offlineIsProjectileActive;

    [Networked, OnChangedRender(nameof(OnProjectileCollided))] private NetworkBool IsProjectileNetworkCollided { get; set; }

    [Networked] int CurrentOnlineComponentIndex { get; set; }
    private ProjectileComponents currentComponents;

    private float projectileLifeTime;
    private bool isOnlineMode;
    private bool projectileDestroyed;

    private HandEnum projectileHand;
    private PlayerClassEnum projectileClass;

    private int enemyLayer;
    //   [Networked] NetworkBool IsRedTeam { get; set; }
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
        if (isOnlineMode || Object.isActiveAndEnabled) return;

        InitializeProjectileComponents(PunchGestureRefs);
        InitializeProjectileComponents(UpperCutGestureRefs);
    }

    private void OnDestroy() => physicsCollisionEvent.OnCollisionEnterEvent.RemoveListener(OnPhysicsCollisionEnter);

    public void InitializeProjectile(PlayerTeamEnum playerTeam, bool onlineMode, float lifeTime, HandEnum hand, PlayerClassEnum playerClass)
    {
        projectileClass = playerClass;
        projectileLifeTime = lifeTime;
        isOnlineMode = onlineMode;
        projectileHand = hand;
        //enemyLayer = playerTeam == PlayerTeamEnum.RedTeam ? "BlueTeam" : "RedTeam";

        isRedTeam = playerTeam == PlayerTeamEnum.RedTeam;
        string enemyLayerName = playerTeam == PlayerTeamEnum.RedTeam ? "BlueTeam" : "RedTeam";
        enemyLayer = LayerMask.NameToLayer(enemyLayerName);

        // RPC_SetProjectileLayer(playerTeam == PlayerTeamEnum.RedTeam);
    }

    //[Rpc(RpcSources.StateAuthority, RpcTargets.All)]
    //public void RPC_SetProjectileLayer(bool isRedTeam)
    //{
    //    int layer = LayerMask.NameToLayer(isRedTeam ? "ProjectileRedTeam" : "ProjectileBlueTeam");

    //    SetLayerRecursively(gameObject, layer);
    //}

    //private void SetLayerRecursively(GameObject obj, int newLayer)
    //{
    //    if (obj == null) return;

    //    obj.layer = newLayer;

    //    foreach (Transform child in obj.transform)
    //        SetLayerRecursively(child.gameObject, newLayer);
    //}

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
        Debug.LogError($"ativating projetile:  {projectileType}");
        projectileDestroyed = false;
        DOVirtual.DelayedCall(4, TryDeactivateProjectile); //projectileLifeTime

        int index = (int)projectileType;

        if (isOnlineMode) CurrentOnlineComponentIndex = index;
        if (Object.HasStateAuthority || !isOnlineMode) currentComponents = GetProjectileComponents(index);

        if (isOnlineMode)
        {
            IsProjectileActive = true;
        }
        else
        {
            offlineIsProjectileActive = true;
            ToggleProjectile(true);
        }
    }
    // public static void OnComponentsUpdated(Changed<Projectile> changed) => changed.Behaviour.UpdateCurrentComponents();

    //private void UpdateCurrentComponents(int index) => currentComponents = (index == 0) ? PunchGestureRefs : UpperCutGestureRefs;

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

    private void TryDeactivateProjectile()
    {
        Debug.LogError("trying to deativate projetile");
        if (projectileDestroyed) return;

        projectileDestroyed = true;

        if (isOnlineMode)
        {
            IsProjectileActive = false;
        }
        else
        {
            offlineIsProjectileActive = false;
            ToggleProjectile(true);
        }
    }

    public void OnToggleActiveProjectile() => ToggleProjectile(IsProjectileActive);

    private void ToggleProjectile(bool isActivated)
    {
        bool isActive = isActivated; //isOnlineMode ? IsProjectileActive : offlineIsProjectileActive;
        if (!Object.HasStateAuthority) currentComponents = GetProjectileComponents(CurrentOnlineComponentIndex);

        if (isActive)
        {
            currentComponents.GestureParticle.transform.localScale = Vector3.one;
           // HandleParticlesDettachment(currentComponents.MuzzleTuple);
            currentComponents.ParentGesture.SetActive(true);
            projectilePhysics.SetActive(true);
            currentComponents.collider.enabled = true;
        }
        else
        {
            Debug.LogError("partiles deativated");

            if (isOnlineMode) IsProjectileNetworkCollided = false;
            currentComponents.collider.enabled = false;
            currentComponents.GestureParticle.transform.DOScale(0, 0.225f)
                .SetEase(Ease.OutQuart)
                .OnComplete(() => ReturnProjectileToPool());
        }
        Debug.LogError("partiles ativated");
    }

    private void ReturnProjectileToPool()
    {
        projectileDestroyed = false;
        projectilePhysics.SetActive(false);
        currentComponents.ParentGesture.SetActive(false);

        if (Object.HasStateAuthority) projectileChannel.ReturnProjectileToPool(projectilePhysics, projectileHand, projectileClass);
    }

    private void OnPhysicsCollisionEnter(Collision collision)
    {
        if (isOnlineMode && Object.HasStateAuthority)
            IsProjectileNetworkCollided = true;
        else
            HandleParticlesDettachment(currentComponents.CollisionTuple);

        TryDeactivateProjectile();
    }

    private void OnTriggerEnterEvent(Collider collider)
    {
        if (!isOnlineMode || !Object.HasStateAuthority || collider.gameObject.layer != enemyLayer) return;

        if (isRedTeam) healthChannel.OnDamageBlueTeam(10);
        else healthChannel.OnDamageRedTeam(10);

        IsProjectileNetworkCollided = true;
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
        particleHandler.ParticleSystem.transform.parent = null;
        particleHandler.ParticleSystem.Play(true);

        DOVirtual.DelayedCall(5f, () => HandleParticlesAttachment(particleHandler));
    }

    private void HandleParticlesAttachment(ProjectileParticleHandler particleHandler)
    {
        particleHandler.ParticleSystem.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);

        particleHandler.ParticleSystem.transform.SetParent(particleHandler.ParentGameObject.transform);
        particleHandler.ParticleSystem.transform.SetLocalPositionAndRotation(particleHandler.OriginalPosition, particleHandler.OriginalRotation);
    }
}
