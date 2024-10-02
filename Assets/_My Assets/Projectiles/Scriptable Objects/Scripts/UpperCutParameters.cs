using UnityEngine;
using UnityEngine.Serialization;

[CreateAssetMenu(fileName = "UpperCutParameters", menuName = "UpperCutParameters", order = 0)]
public class UpperCutParameters : ScriptableObject
{
    public float minDotToUpperCut;
    public float canPunchMaxDot;
    public int handMaxRotationToUpperCut;

    public float upperCutDelay;
    public float limitTimeCanUpperCut;
    public float handMinDistanceToStartUpperCut; 
    public float handMinYDistanceFromStartToUpperCut;
    public float handMinXDistanceFromStartToUpperCut;
    public float maxYDistanceBeforeForwardMovement;

    [HideInInspector] public float timeWhenStartUpperCut;
    [HideInInspector] public float horizontalDistance;
    [HideInInspector] public float yPositionWhenMovedForward;
    [HideInInspector] public bool handMovedForward;
}