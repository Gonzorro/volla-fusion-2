using UnityEngine;

[CreateAssetMenu(fileName = "PunchParameters", menuName = "PunchParameters", order = 0)]
public class PunchParameters : ScriptableObject
{
    public float punchDelay;
    public float minDotToPunch;
    public float canPunchMaxDot;
    public float timeCanPunch;
    public int handMaxRotationToPunch;
    public float handMinDistanceToPunch;
    public float handMinDistanceFromStartToPunch;
}
