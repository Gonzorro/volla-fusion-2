using UnityEngine;

public class HookGesture : GestureBase, IGesture
{

    public void TrackGesture()
    {
        // Check if enough time has passed since the last hook
        if (Time.time < lastPunchTime + hookParameters.hookDelay) return;

        handVelocity = velocityProperty.action.ReadValue<Vector3>();

        currentHandVelocityMagnitude = handVelocity.magnitude;

        // Check if the hand velocity is below the threshold
        if (currentHandVelocityMagnitude < hookParameters.minHandVelocityToTriggerHook)
        {
            // If the hand is at a certain distance from the head and not too high or low
            if (Mathf.Abs(transform.position.y - cam.transform.position.y) < hookParameters.handMaxYDistanceFromHead
                && Vector3.Distance(transform.position, cam.position) > hookParameters.handMinDistanceToStartHook)
            {
                print("Starting Hook");
                hookParameters.timeWhenStartHook = Time.time;
                handDistanceFromStart = transform.position;
                canLaunchProjectile = true;
            }
        }

        if (!canLaunchProjectile) return;

        // Check if the hook has taken too long to complete
        if (Time.time > hookParameters.timeWhenStartHook + hookParameters.limitTimeCanHook)
        {
            print("Too slow");

            canLaunchProjectile = false;
            hookParameters.handMovedSideways = false;

            return;
        }

        // Check if the hand moved sideways
        if (!hookParameters.handMovedSideways)
        {
            var position = transform.position;

            hookParameters.horizontalDistance = Vector3.Distance(new Vector3(0, position.y, position.z),
                new Vector3(0, handDistanceFromStart.y, handDistanceFromStart.z));

            if (hookParameters.horizontalDistance < hookParameters.handMinZDistanceFromStartToHook) return;

            hookParameters.handMovedSideways = true;
        }

        // Check if the hand moved forward enough during the hook
        if (Vector3.Distance(new Vector3(transform.position.x, 0, 0), new Vector3(handDistanceFromStart.x, 0, 0)) <
            hookParameters.handMinXDistanceFromStartToHook) return;

        // Check if the hand is in front of the player
        if (Vector3.Dot((transform.position - handDistanceFromStart).normalized, cam.forward) <= 0) return;

        // Check if the hand moved forward enough during the hook
        if (Vector3.Distance(new Vector3(transform.position.x, 0, 0), new Vector3(handDistanceFromStart.x, 0, 0)) <
            hookParameters.minHandFrontDistanceToHook) return;

        // // Calculate the angle between the starting position and the current position in the XZ plane
        // var startPosXZ = new Vector3(handDistanceFromStart.x, 0, handDistanceFromStart.z);
        // var currentPosXZ = new Vector3(transform.position.x, 0, transform.position.z);
        // var angleBetweenPositions = Vector3.Angle(startPosXZ - cam.position, currentPosXZ - cam.position);
        //
        //
        // // Check if the angle is within the acceptable range for a horizontal hook
        // if (angleBetweenPositions is < minHorizontalAngle or > maxHorizontalAngle) return;
        //
        // // Check if the hand is in front of the player
        // if (Vector3.Dot((transform.position - handDistanceFromStart).normalized, cam.forward) <= 0) return;

        // // Calculate the cross product of the starting position and the current position in the XZ plane
        // var startPosXZ = new Vector3(handDistanceFromStart.x, 0, handDistanceFromStart.z);
        // var currentPosXZ = new Vector3(transform.position.x, 0, transform.position.z);
        // var crossProduct = Vector3.Cross(startPosXZ - cam.position, currentPosXZ - cam.position);
        //
        // // Determine if the hand has moved to the left or right
        // var handMovedLeft = crossProduct.y < 0;
        // // bool handMovedRight = crossProduct.y > 0;
        //
        // if (isRightHand && !handMovedLeft) return;
        // Uncomment the following lines if you want to print the direction for debugging purposes
        // if (handMovedLeft) print("Hand moved left");
        // if (handMovedRight) print("Hand moved right");

        // Add your desired conditions using handMovedLeft or handMovedRight
        // For example, if you want to trigger the hook only when the hand moves to the left:
        ///////////////////  projectilePool.LaunchPooledProjectile(projectileLaunchTransform, projectileType);

        canLaunchProjectile = false;
        hookParameters.handMovedSideways = false;
        lastPunchTime = Time.time;
    }

    public void InitializeGesture(PunchParameters punchParameters, UpperCutParameters upperCutParameters, HookParameters hookParameters, Transform cam, ProjectileChannel projectileChannel, Transform launchTransform, HandEnum hand)
    {
        this.punchParameters = punchParameters;
        this.upperCutParameters = upperCutParameters;
        this.hookParameters = hookParameters;
        this.cam = cam;
        this.projectileChannel = projectileChannel;
        this.launchPosition= launchTransform;
        this.hand = hand;
    }

}
