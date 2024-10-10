using Fusion;
using Oculus.Voice.Core.Bindings.Interfaces;
using UnityEngine;

public class MaterialNetwork : MonoBehaviour
{
    [SerializeField] private NetworkRunnerChannel networkRunnerChannel;

    [SerializeField] private MeshRenderer meshRenderer;
    [SerializeField] private Material successfulMat;

    private void Start() => networkRunnerChannel.NetworkEvents.OnConnectedToServer.AddListener(SetSuccessfulMaterial);

    private void SetSuccessfulMaterial(NetworkRunner arg0) =>  meshRenderer.material = successfulMat;
}
