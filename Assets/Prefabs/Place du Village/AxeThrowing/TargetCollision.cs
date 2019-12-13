using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetCollision : MonoBehaviour {

    public Rigidbody rb;
    public AudioSource hitSound;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "AxeTarget")
        {
            hitSound.Play();
            transform.parent = other.transform.parent;
            rb.isKinematic = true;
            StartCoroutine(StartCountdown());
        }
    }

    float currCountdownValue;
    public IEnumerator StartCountdown(float countdownValue = 15)
    {
        currCountdownValue = countdownValue;
        while (currCountdownValue > 0)
        {
            Debug.Log("Countdown: " + currCountdownValue);
            yield return new WaitForSeconds(1.0f);
            currCountdownValue--;
        }
        Destroy(gameObject);
    }
}
