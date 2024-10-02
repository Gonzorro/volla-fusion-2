using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class HandGestureTracker : MonoBehaviour
{
    [Header("Channels")]
    [SerializeField] private ProjectileChannel projectileChannel;
    [SerializeField] private HandEnum hand;

    [Header("Gestures Parameters")]
    [SerializeField] private PunchParameters punchParameters;
    [SerializeField] private UpperCutParameters upperCutParameters;
    [SerializeField] private HookParameters hookParameters;

    [Header("References")]
    [SerializeField] private Transform cam;
    [SerializeField] private Transform projectileLaunchTransform;

    [Header("Input Action")]
    [SerializeField] private InputActionProperty velocityProperty;

    private Vector3 HandVelocity { get; set; } = Vector3.zero;

    //[SerializeField, Range(0f, 2f)] private float punchDelay = 0.25f;
    //[SerializeField, Range(0f, 1f)] private float minDotToPunch = 0.75f;
    //[SerializeField, Range(0f, 1f)] private float canPunchMaxDot = 0.175f;
    //[SerializeField, Range(0f, 10f)] private float timeCanPunch = 0.135f;
    //[SerializeField, Range(0, 150)] private int handMaxRotationToPunch = 100;
    //[SerializeField, Range(0f, 1f)] private float handMinDistanceFromStartToPunch = 0.4f;
    //[SerializeField] private float handMinDistanceToPunch = 2;

    public float minHandVelocityToTriggerUpperCute = 2f;
    private float currentHandVelocityMagnitude;

    [Header("Special Move")]
    [SerializeField] private int specialMoveThreshold = 10;

    private float handAngle;
    private float lastPunchTime;
    private float handDotPosition;
    private float timeWhenCanPunch;
    private float handDistanceToHead;
    private float handDistanceFromHandStart;
    private Vector3 handDistanceFromStart;
    private bool canLaunchProjectile;

    private int projectileCounter;
    private ProjectilePool projectilePool;

    [SerializeField] private ProjectileType projectileType;

    private void Awake()
    {
        //    InitializeParameters();

    //    projectileChannel.OnRequestNetworkObjectPool += GetPoolSystem;
        //     projectileType = ProjectileType.Punch;
    }

    private void InitializeParameters()
    {
        upperCutParameters.handMovedForward = false;
    }

    //private void OnDestroy() => projectileChannel.OnRequestNetworkObjectPool -= GetPoolSystem;

    private void GetPoolSystem(ProjectilePool poolSystem)
    {
        print("Getting Pool System");
        projectilePool = poolSystem;
    }

    private void Update()
    {
      //  if (!GameStateSync.CanPunch) return;

        switch (projectileType)
        {
            case ProjectileType.Punch:
                Punch();
                break;
            case ProjectileType.UpperCut:
                UpperCut();
                break;
            case ProjectileType.Hook:
                Hook();
                break;
            case ProjectileType.PunchUpperCut:
                PunchUpperCut();
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }

        HandVelocity = velocityProperty.action.ReadValue<Vector3>();
        // print(punchParameters.handMaxRotationToPunch);
    }

    bool canPunch;
    bool canUpperCut;

    private void PunchUpperCut()
    {
        currentHandVelocityMagnitude = HandVelocity.magnitude;

        if (currentHandVelocityMagnitude < 1f) return;

        // Check if the hand is above the head
        if (transform.position.y > cam.transform.position.y) return;

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
        else if (Vector3.Distance(transform.position, cam.position) > upperCutParameters.handMinDistanceToStartUpperCut)
        {
            // Starting UpperCut
            upperCutParameters.timeWhenStartUpperCut = Time.time;
            handDistanceFromStart = transform.position;
            canUpperCut = true;
            canPunch = false;
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

     ////////////////////////       projectilePool.LaunchPooledProjectile(projectileLaunchTransform, ProjectileType.Punch);

            canPunch = false;
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
         ////////////////////////       projectilePool.LaunchPooledProjectile(projectileLaunchTransform, ProjectileType.UpperCut);

                canUpperCut = false;
                lastPunchTime = Time.time;
            }
        }
    }

    private void Punch()
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
        // textMeshDot.text = a.ToString("F1");

        if (!canLaunchProjectile) return;

        if (Time.time > timeWhenCanPunch + punchParameters.timeCanPunch)
        {
            canLaunchProjectile = false;
            return;
        }

        if (Vector3.Distance(transform.position, cam.position) < punchParameters.handMinDistanceToPunch) return;
        print("Di0stance completed");

        handDistanceFromHandStart = Vector3.Distance(handDistanceFromStart, transform.position);
        if (handDistanceFromHandStart < punchParameters.handMinDistanceFromStartToPunch) return;

        print("min distance from start");

        handAngle = Quaternion.Angle(transform.rotation, cam.rotation);
        if (handAngle < punchParameters.handMaxRotationToPunch) return;

        if (handDotPosition < punchParameters.minDotToPunch) return;

        if (projectileCounter < specialMoveThreshold)
        {
      //////////////////      projectilePool.LaunchPooledProjectile(projectileLaunchTransform, projectileType);

            projectileCounter++;
        }
        else
        {
            print("Special Projectile");
            projectileCounter = 0;
        }

        canLaunchProjectile = false;
        lastPunchTime = Time.time;
    }

    private void UpperCut()
    {
        currentHandVelocityMagnitude = HandVelocity.magnitude;

        // If the hand is below the head AND a certain distance, you can start the uppercut
        if (currentHandVelocityMagnitude < minHandVelocityToTriggerUpperCute)
        {
            if (transform.position.y < cam.transform.position.y
                && Vector3.Distance(transform.position, cam.position) >
                upperCutParameters.handMinDistanceToStartUpperCut)
            {
                print("Starting UpperCut");
                upperCutParameters.timeWhenStartUpperCut = Time.time;
                handDistanceFromStart = transform.position;
                canLaunchProjectile = true;
            }
        }

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

    private void Hook()
    {
        // Check if enough time has passed since the last hook
        if (Time.time < lastPunchTime + hookParameters.hookDelay) return;

        currentHandVelocityMagnitude = HandVelocity.magnitude;

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
}