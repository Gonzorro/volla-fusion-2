using System;
using UnityEngine;

public class ProjectileChannel : ScriptableObject
{
    public Action<Transform, ProjectileType, HandEnum> OnLaunchProjectile;
    public void LaunchProjectile(Transform launchPosition, ProjectileType projectileType, HandEnum hand) => OnLaunchProjectile?.Invoke(launchPosition, projectileType, hand);

    //public Action<Transform, ProjectileType, HandEnum> OnLaunchClassProjectile;
    //public void LaunchClassProjectile(Transform launchPosition, ProjectileType projectileType, HandEnum hand) => OnLaunchClassProjectile?.Invoke(launchPosition, projectileType, hand);

    public Action<GameObject, HandEnum, PlayerClassEnum> OnReturnProjectileToPool;
    public void ReturnProjectileToPool(GameObject projectile, HandEnum hand, PlayerClassEnum playerClass) => OnReturnProjectileToPool?.Invoke(projectile, hand, playerClass);
}