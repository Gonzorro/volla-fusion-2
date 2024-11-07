using Oculus.Interaction;
using UnityEngine;

public class ClassChanger : MonoBehaviour
{
    [SerializeField] private PlayerInfoChannel playerInfoChannel;
    [SerializeField] private PokeInteractable guardPoke;
    [SerializeField] private PokeInteractable strikerPoke;
    [SerializeField] private PokeInteractable wingPoke;

    private void Awake()
    {
        guardPoke.WhenPointerEventRaised += OnGuardPokeClicked;
        strikerPoke.WhenPointerEventRaised += OnStrikerPokeClicked;
        wingPoke.WhenPointerEventRaised += OnWingPokeClicked;
    }

    private void OnDestroy()
    {
        guardPoke.WhenPointerEventRaised -= OnGuardPokeClicked;
        strikerPoke.WhenPointerEventRaised -= OnStrikerPokeClicked;
        wingPoke.WhenPointerEventRaised -= OnWingPokeClicked;
    }

    private void OnGuardPokeClicked(PointerEvent pointerEvent)
    {
        if (pointerEvent.Type == PointerEventType.Select)
            playerInfoChannel.SetPlayerClass(PlayerClassEnum.Guard);
    }

    private void OnStrikerPokeClicked(PointerEvent pointerEvent)
    {
        if (pointerEvent.Type == PointerEventType.Select)
            playerInfoChannel.SetPlayerClass(PlayerClassEnum.Striker);
    }

    private void OnWingPokeClicked(PointerEvent pointerEvent)
    {
        if (pointerEvent.Type == PointerEventType.Select)
            playerInfoChannel.SetPlayerClass(PlayerClassEnum.Wing);
    }
}
