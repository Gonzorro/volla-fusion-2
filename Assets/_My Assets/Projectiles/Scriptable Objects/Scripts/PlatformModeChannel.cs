using UnityEngine;

public enum PlatformModeEnum
{
    MetaPlatform,
    WindowsPlatform
}

//[CreateAssetMenu(fileName = "PlatformModeChannel", menuName = "ScriptableObjects/PlatformModeChannel")]
public class PlatformModeChannel : ScriptableObject
{
    private PlatformModeEnum PlatformMode;

    public void SetPlatformMode(PlatformModeEnum mode)
    {
        PlatformMode = mode;
        Debug.Log(mode.ToString());
    }

    public PlatformModeEnum GetPlatformMode() => PlatformMode;
}