using UnityEngine;

public class UpperCutGesture : GestureBase, IGesture
{
    
    public void TrackGesture()
    {
    //    handVelocity = velocityProperty.action.ReadValue<Vector3>();

   //     currentHandVelocityMagnitude = handVelocity.magnitude;

        // If the hand is below the head AND a certain distance, you can start the uppercut
  //      if (currentHandVelocityMagnitude < 1f)
//        {
            if (transform.position.y < cam.transform.position.y
                && Vector3.Distance(transform.position, cam.position) >
                upperCutParameters.handMinDistanceToStartUpperCut)
            {
                print("Starting UpperCut");
                upperCutParameters.timeWhenStartUpperCut = Time.time;
                handDistanceFromStart = transform.position;
                canLaunchProjectile = true;
            }
 //      }

        if (!canLaunchProjectile) return;

        // time limit to complete the UpperCut
        if (Time.time > upperCutParameters.timeWhenStartUpperCut + upperCutParameters.limitTimeCanUpperCut)
        {
            print("Too slow");

            canLaunchProjectile = false;
            upperCutParameters.handMovedForward = false;

            return;
        }

        // first check if the hand went forward on Z or X axis and that it didn't rise on Y axis before it
        if (!upperCutParameters.handMovedForward)
        {
            var position = transform.position;
            upperCutParameters.horizontalDistance = Vector3.Distance(new Vector3(position.x, 0, position.z),
                new Vector3(handDistanceFromStart.x, 0, handDistanceFromStart.z));

            if (upperCutParameters.horizontalDistance < upperCutParameters.handMinXDistanceFromStartToUpperCut)
            {
                if (transform.position.y - handDistanceFromStart.y >
                    upperCutParameters.maxYDistanceBeforeForwardMovement)
                    canLaunchProjectile = false;

                return;
            }

            upperCutParameters.handMovedForward = true;
        }

        // Check if the hand elevated to a certain Y axis
        if (!(transform.position.y - handDistanceFromStart.y >
              upperCutParameters.handMinYDistanceFromStartToUpperCut)) return;

        print("Upper Cut");

        ////////// projectilePool.LaunchPooledProjectile(projectileLaunchTransform, projectileType);

        canLaunchProjectile = false;
        upperCutParameters.handMovedForward = false;
        lastPunchTime = Time.time;
    }

    public void InitializeGesture(PunchParameters punchParameters, UpperCutParameters upperCutParameters, HookParameters hookParameters, Transform cam, ProjectileChannel projectileChannel,Transform launchTransform, HandEnum hand)
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
