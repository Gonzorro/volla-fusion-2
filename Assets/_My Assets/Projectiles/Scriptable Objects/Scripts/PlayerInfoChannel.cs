using UnityEngine;

public enum PlayerClassEnum { Guard, Striker, Wing }
public enum PlayerTeamEnum { RedTeam, BlueTeam, None }
public enum PlayerSpawnPointEnum { First, Second, Third }
public enum PlayerStrongHandEnum { RightHand, LeftHand }
public enum PlayerVrModeEnum { Player, Spectator }

//[CreateAssetMenu(fileName = "PlayerInfoChannel", menuName = "ScriptableObjects/PlayerInfoChannel")]
public class PlayerInfoChannel : ScriptableObject
{
    private string PlayerName;
    public void SetPlayerName(string inPlayerName) => PlayerName = inPlayerName;
    public string GetPlayerName() => PlayerName;

    private PlayerTeamEnum PlayerTeam;
    public void SetPlayerTeam(PlayerTeamEnum inPlayerTeam) => PlayerTeam = inPlayerTeam;
    public PlayerTeamEnum GetPlayerTeam() => PlayerTeam;

    private PlayerSpawnPointEnum PlayerSpawnPoint;
    public void SetSpawnPoint(PlayerSpawnPointEnum inPlayerSpawnPoint) => PlayerSpawnPoint = inPlayerSpawnPoint;
    public PlayerSpawnPointEnum GetPlayerSpawnPoint() => PlayerSpawnPoint;

    private PlayerClassEnum PlayerClass;
    public void SetPlayerClass(PlayerClassEnum inPlayerClass) => PlayerClass = inPlayerClass;
    public PlayerClassEnum GetPlayerClass() => PlayerClass;

    public PlayerStrongHandEnum PlayerStrongHand;
    public void SetPlayerStrongHand(PlayerStrongHandEnum inPlayerStrongHand) => PlayerStrongHand = inPlayerStrongHand;
    public PlayerStrongHandEnum GetPlayerStrongHand() => PlayerStrongHand;

    public PlayerVrModeEnum playerVrMode;
    public void SetPlayerVrMode(PlayerVrModeEnum inPlayerVrMode) => playerVrMode = inPlayerVrMode;
    public PlayerVrModeEnum GetPlayerVrMode() => playerVrMode;
}