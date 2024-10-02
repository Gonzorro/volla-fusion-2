using UnityEngine;
using DG.Tweening;

public enum ProjectileType { Punch, UpperCut, Hook, PunchUpperCut }
public enum HandEnum { RightHand, LeftHand }

public class GestureTracker : MonoBehaviour
{
    [Header("Channels")]
    [SerializeField] private ProjectileChannel projectileChannel;

    [Header("Gestures")]
    [SerializeField] private PunchParameters punchParameters;
    [SerializeField] private UpperCutParameters upperCutParameters;
    [SerializeField] private HookParameters hookParameters;

    [Header("Parameters")]
    [SerializeField] private Transform cam;
    [SerializeField] private Transform launchPosition;

    [SerializeField] private ProjectileType CurrentProjectileType;

    [SerializeField] private HandEnum hand;

    public IGesture[] gestures;

    private IGesture currentGestureTracked;

    private bool canTrackGesture;
    private bool isInputFocusLost;

    private void Awake()
    {
        OVRManager.InputFocusLost += OVRManager_InputFocusLost;
        OVRManager.InputFocusAcquired += OVRManager_InputFocusAcquired;
    }

    private void OnDestroy()
    {
        OVRManager.InputFocusLost -= OVRManager_InputFocusLost;
        OVRManager.InputFocusAcquired -= OVRManager_InputFocusAcquired;
        OVRManager.TrackingLost += OVRManager_TrackingLost;
    }

    private void OVRManager_TrackingLost()
    {
        throw new System.NotImplementedException();
    }

    private void OVRManager_InputFocusLost() => isInputFocusLost = true;

    private void OVRManager_InputFocusAcquired() => DOVirtual.DelayedCall(0.5f, () => isInputFocusLost = false);

    private void Start()
    {
        InitializeGestures();
        SwapProjectileType(CurrentProjectileType);
    }

    private void InitializeGestures()
    {
        var gestures = GetComponents<IGesture>();

        foreach (var gesture in gestures)
            gesture.InitializeGesture(punchParameters, upperCutParameters, hookParameters, cam, projectileChannel, launchPosition, hand);
    }

    private void SwapProjectileType(ProjectileType projectileType)
    {
        canTrackGesture = false;

        switch (projectileType)
        {
            case ProjectileType.Punch:
                currentGestureTracked = GetComponent<PunchGesture>();
                break;
            case ProjectileType.UpperCut:
                currentGestureTracked = GetComponent<UpperCutGesture>();
                break;
            case ProjectileType.PunchUpperCut:
                currentGestureTracked = GetComponent<PunchUpperCutGesture>();
                break;
        }

        canTrackGesture = true;
    }

    private void Update()
    {
        if (!isInputFocusLost && canTrackGesture) currentGestureTracked.TrackGesture();
    }
}
