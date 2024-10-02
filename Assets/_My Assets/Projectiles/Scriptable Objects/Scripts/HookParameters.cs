using UnityEngine;
using UnityEngine.Serialization;

[CreateAssetMenu(fileName = "HookParameters", menuName = "HookParameters", order = 0)]
public class HookParameters : ScriptableObject
{
    public float minDotToUpperCut;
    public float canPunchMaxDot;
    public int handMaxRotationToUpperCut;

    public float hookDelay;
    public float limitTimeCanHook;
    public float handMinZDistanceFromStartToHook; 
    public float handMinDistanceToStartHook;
    public float handMaxYDistanceFromHead;
    public float handMinXDistanceFromStartToHook;
    public float minHandVelocityToTriggerHook;
    public float minHandFrontDistanceToHook;
    
    [HideInInspector] public float timeWhenStartHook;
    [HideInInspector] public float horizontalDistance;
    [HideInInspector] public bool handMovedSideways;
}