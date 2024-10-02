using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;

public class PunchUpperCutGesture : GestureBase, IGesture
{
  //  [SerializeField] private TextMeshPro debug;
    public void TrackGesture()
    {
        if (Keyboard.current.lKey.wasPressedThisFrame)
        {
            Debug.LogError("Gesture Launching Uppercut");
            projectileChannel.LaunchProjectile(launchPosition, ProjectileType.UpperCut, hand);
        }
        //handVelocity = velocityProperty.action.ReadValue<Vector3>();
        //if (handVelocity.magnitude < 1f) return;

        // Check if the hand is above the head
        //  if (transform.position.y > cam.transform.position.y) return;

        // Check the dot product with the camera forward vector
        float dotProduct = Vector3.Dot((transform.position - cam.position).normalized, cam.forward);

        if (dotProduct < punchParameters.canPunchMaxDot)
        {
            // Starting Punch
            timeWhenCanPunch = Time.time;
            handDistanceFromStart = transform.position;
            canPunch = true;
            canUpperCut = false;
        }
        //  if (hand == HandEnum.RightHand) debug.text = $"Distance: {transform.position.y - handDistanceFromStart.y > upperCutParameters.handMinYDistanceFromStartToUpperCut} ";
        if (Vector3.Distance(transform.position, cam.position) > upperCutParameters.handMinDistanceToStartUpperCut)
        {
            // Starting UpperCut
            upperCutParameters.timeWhenStartUpperCut = Time.time;
            handDistanceFromStart = transform.position;
            canUpperCut = true;
            canPunch = false;
            //projectileChannel.LaunchProjectile(launchPosition, ProjectileType.UpperCut, hand);
        }

        if (canPunch)
        {
            if (Time.time > timeWhenCanPunch + punchParameters.timeCanPunch)
            {
                canPunch = false;
                return;
            }

            if (Vector3.Distance(transform.position, cam.position) < punchParameters.handMinDistanceToPunch) return;

            handDistanceFromHandStart = Vector3.Distance(handDistanceFromStart, transform.position);
            if (handDistanceFromHandStart < punchParameters.handMinDistanceFromStartToPunch) return;

        //    Debug.LogError("Punch Launched");
            projectileChannel.LaunchProjectile(launchPosition, ProjectileType.Punch, hand);

            canPunch = false;
            canUpperCut = false;
            lastPunchTime = Time.time;
        }
        else if (canUpperCut)
        {
            // Check the time limit to complete the UpperCut
            if (Time.time > upperCutParameters.timeWhenStartUpperCut + upperCutParameters.limitTimeCanUpperCut)
            {
                canUpperCut = false;
                return;
            }

            // Check if the hand has moved forward on the Y axis
            if (transform.position.y - handDistanceFromStart.y > upperCutParameters.handMinYDistanceFromStartToUpperCut)
            {
            //    Debug.LogError("UpperCut Launched");
                projectileChannel.LaunchProjectile(launchPosition, ProjectileType.UpperCut, hand);
                canUpperCut = false;
                canPunch = false;
                lastPunchTime = Time.time;
            }
        }
    }

    public void InitializeGesture(PunchParameters punchParameters, UpperCutParameters upperCutParameters, HookParameters hookParameters, Transform cam, ProjectileChannel projectileChannel, Transform launchPosition, HandEnum hand)
    {
        this.punchParameters = punchParameters;
        this.upperCutParameters = upperCutParameters;
        this.hookParameters = hookParameters;
        this.cam = cam;
        this.projectileChannel = projectileChannel;
        this.launchPosition = launchPosition;
        this.hand = hand;
    }
}
