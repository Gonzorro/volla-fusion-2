using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class GestureSoundManager : MonoBehaviour
{
    private AudioSource audioSource;

    private void Awake()
    {
        // Get the AudioSource component attached to this GameObject
        audioSource = GetComponent<AudioSource>();
    }

    private void OnEnable()
    {
        // Set a random pitch between 0.97 and 1.03
        audioSource.pitch = Random.Range(0.97f, 1.03f);

        // Play the sound from the beginning
        audioSource.Stop(); // Ensure the sound is stopped so it starts from the beginning
        audioSource.Play();
    }

    private void OnDisable()
    {
        // Stop the sound when the GameObject is disabled
        audioSource.Stop();
    }
}
