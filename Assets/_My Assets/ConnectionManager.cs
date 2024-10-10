using Fusion;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ConnectionManager : MonoBehaviour
{
    [SerializeField] private NetworkRunnerChannel networkRunnerChannel;
    [SerializeField] private GameMode gameMode;
    private NetworkRunner networkRunner;

    private void Awake()
    {
        networkRunnerChannel.InstantiateNetworkRunnerPrefab();
        networkRunner = networkRunnerChannel.NetworkRunner;

        StartGame();
    }

    private void StartGame()
    {
        if (TryGetSceneRef(out var sceneRef))
        {
            networkRunner.StartGame(new StartGameArgs()
            {
                GameMode = gameMode,
                Scene = sceneRef,
                SessionName = "TestSession",
                PlayerCount = 2
            });
        }
        else
        {
            Debug.LogError("Invalid scene reference. Cannot start the game.");
        }
    }

    private bool TryGetSceneRef(out SceneRef sceneRef)
    {
        var activeScene = SceneManager.GetActiveScene();
        if (activeScene.buildIndex < 0 || activeScene.buildIndex >= SceneManager.sceneCountInBuildSettings)
        {
            sceneRef = default;
            return false;
        }
        else
        {
            sceneRef = SceneRef.FromIndex(activeScene.buildIndex);
            return true;
        }
    }
}
