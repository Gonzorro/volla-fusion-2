using UnityEngine;

public class PunchGesture : GestureBase, IGesture
{
    public void TrackGesture()
    {
        if (Time.time < lastPunchTime + punchParameters.punchDelay) return;

        handDotPosition = Vector3.Dot((transform.position - cam.position).normalized, cam.forward);

        if (handDotPosition < punchParameters.canPunchMaxDot)
        {
            timeWhenCanPunch = Time.time;
            handDistanceFromStart = transform.position;
            canLaunchProjectile = true;
        }

        // var cameraToHand = _handTransform.position - cam.position;
        //
        // var rotation = Quaternion.LookRotation(cameraToHand, cam.up);
        // var a = Quaternion.Angle(cam.rotation, rotation);


        if (!canLaunchProjectile) return;

        if (Time.time > timeWhenCanPunch + punchParameters.timeCanPunch)
        {
            canLaunchProjectile = false;
            return;
        }

        if (Vector3.Distance(transform.position, cam.position) < punchParameters.handMinDistanceToPunch) return;

        handDistanceFromHandStart = Vector3.Distance(handDistanceFromStart, transform.position);
        if (handDistanceFromHandStart < punchParameters.handMinDistanceFromStartToPunch) return;


        handAngle = Quaternion.Angle(transform.rotation, cam.rotation);
        if (handAngle < punchParameters.handMaxRotationToPunch) return;

        if (handDotPosition < punchParameters.minDotToPunch) return;

        projectileChannel.LaunchProjectile(launchPosition, ProjectileType.Punch, hand);

        canLaunchProjectile = false;
        lastPunchTime = Time.time;
    }

    public void InitializeGesture(PunchParameters punchParameters, UpperCutParameters upperCutParameters, HookParameters hookParameters, Transform cam, ProjectileChannel projectileChannel, Transform launchTransform, HandEnum hand)
    {
        this.punchParameters = punchParameters;
        this.upperCutParameters = upperCutParameters;
        this.hookParameters = hookParameters;
        this.cam = cam;
        this.projectileChannel = projectileChannel;
        this.launchPosition = launchTransform;
        this.hand = hand;
    }
}
