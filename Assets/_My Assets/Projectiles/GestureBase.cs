using Oculus.Interaction.Input;
using UnityEngine;
using UnityEngine.InputSystem;

public class GestureBase : MonoBehaviour
{
    protected ProjectileChannel projectileChannel;
    protected PunchParameters punchParameters;
    protected UpperCutParameters upperCutParameters;
    protected HookParameters hookParameters;

    protected Transform cam;
    protected Transform launchPosition;

    protected InputActionProperty velocityProperty;

    protected HandEnum hand;

    protected float handAngle;
    protected float lastPunchTime;
    protected float handDotPosition;
    protected float timeWhenCanPunch;
    protected float handDistanceToHead;
    protected float handDistanceFromHandStart;
    protected float currentHandVelocityMagnitude;

    protected bool canLaunchProjectile;
    protected bool canPunch;
    protected bool canUpperCut;

    protected Vector3 handDistanceFromStart;
    protected Vector3 handVelocity = Vector3.zero;
}
