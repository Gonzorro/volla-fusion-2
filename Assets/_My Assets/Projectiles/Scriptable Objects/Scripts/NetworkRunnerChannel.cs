using Fusion;
using System;
using UnityEngine;
using System.Threading.Tasks;

public class NetworkRunnerChannel : ScriptableObject
{
    public NetworkRunner NetworkRunner;
    public NetworkEvents NetworkEvents;

    public Action OnDisconnectedFromServer;

    private GameObject currentNetworkRunner;

    public void InstantiateNetworkRunnerPrefab()
    {
        currentNetworkRunner = Instantiate(Resources.Load<GameObject>("NetworkRunnerPrefab"));

        NetworkRunner = currentNetworkRunner.GetComponent<NetworkRunner>();
        NetworkEvents = currentNetworkRunner.GetComponent<NetworkEvents>();

        //  NetworkEvents.OnDisconnectedFromServer.AddListener(DisconnectedFromServer);
        NetworkEvents.OnShutdown.AddListener(OnShutDown);
    }

    private void OnShutDown(NetworkRunner arg0, ShutdownReason arg1)
    {
        Debug.LogError("Server Shut Down");
        OnDisconnectedFromServer?.Invoke();
    }

    private void DisconnectedFromServer(NetworkRunner networkRunner)
    {
        Debug.LogError("Disconnected");
        OnDisconnectedFromServer?.Invoke();
    }

    public async Task RenewNetworkRunner()
    {
        //   NetworkEvents.OnDisconnectedFromServer.RemoveListener(DisconnectedFromServer);
        NetworkEvents.OnShutdown.RemoveListener(OnShutDown);

        await NetworkRunner.Shutdown(destroyGameObject: false);

        Destroy(currentNetworkRunner);

        InstantiateNetworkRunnerPrefab();
    }

    public async Task DisconnectRunner()
    {
        NetworkEvents.OnShutdown.RemoveListener(OnShutDown);

        await NetworkRunner.Shutdown(destroyGameObject: true);
    }
}