using UnityEngine;
using UnityEngine.Events;

[System.Serializable]
public class CollisionEvent : UnityEvent<Collision> { }

[System.Serializable]
public class TriggerEvent : UnityEvent<Collider> { }

public class ProjectileCollisionEvent : MonoBehaviour
{
    public CollisionEvent OnCollisionEnterEvent;

    private void OnCollisionEnter(Collision collision) => OnCollisionEnterEvent.Invoke(collision);

    public TriggerEvent OnTriggerEnterEvent;

    private void OnTriggerEnter(Collider other) => OnTriggerEnterEvent.Invoke(other);
}
