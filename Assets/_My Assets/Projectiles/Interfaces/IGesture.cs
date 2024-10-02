using UnityEngine;

public interface IGesture
{
    void TrackGesture();
    void InitializeGesture(PunchParameters punchParameters, UpperCutParameters upperCutParameters, HookParameters hookParameters, Transform cam, ProjectileChannel projectileChannel, Transform launchTransform, HandEnum hand);
}