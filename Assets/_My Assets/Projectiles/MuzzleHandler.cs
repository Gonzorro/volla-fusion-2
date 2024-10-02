using DG.Tweening;
using UnityEngine;

public class MuzzleHandler : MonoBehaviour
{
    [SerializeField] private ParticleSystem muzzleParticle;
    private float particleLifeTime;
    private Transform originalParent;
    private Vector3 originalPosition;
    private Quaternion originalRotation;

    private void Awake()
    {
        ParticleSystem.MainModule mainModule = muzzleParticle.main;
        particleLifeTime = mainModule.startLifetime.constantMax + mainModule.duration;

        originalParent = transform.parent;
        originalPosition = transform.localPosition;
        originalRotation = transform.rotation;
    }

    private void OnEnable()
    {
        transform.parent = null;
        muzzleParticle.Stop();
        muzzleParticle.Play();

        DOVirtual.DelayedCall(particleLifeTime, () => ResetParticleTransform());
    }

    private void ResetParticleTransform()
    {
        transform.parent = originalParent;
        transform.localPosition = originalPosition;
        transform.rotation = originalRotation;
    }
}
