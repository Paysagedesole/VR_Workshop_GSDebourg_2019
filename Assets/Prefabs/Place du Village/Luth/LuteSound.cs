using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using VRTK;
public class LuteSound : MonoBehaviour {
    public VRTK_InteractableObject lute;
    public AudioSource Sound;

	// Use this for initialization
	void Start () {
        lute.InteractableObjectTouched += Lute_InteractableObjectTouched;
	}

    private void Lute_InteractableObjectTouched(object sender, InteractableObjectEventArgs e )
    {
        Sound.Play();
        Debug.Log("marche");
    }

    // Update is called once per frame
    void Update ()

    {


		
	}
}
