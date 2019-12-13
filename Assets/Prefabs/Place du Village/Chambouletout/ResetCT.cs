using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetCT : MonoBehaviour {

    public int m_numberOfBoxes;
    public float m_resetDelay = 3f;
    public GameObject m_resetButton;
    public TextMesh m_scoreDisplay;

    private Component[] m_boxOriginTransforms;
    private Vector3[]  m_boxOriginPositions;
    private Quaternion[] m_boxOriginRotations;

	void Awake () 
    {
        m_boxOriginPositions = new Vector3[22];
        m_boxOriginRotations = new Quaternion[22];
        //on rentre les Transforms des boites dans une array
        m_boxOriginTransforms = GetComponentsInChildren(typeof(Transform));
        for (int i = 1; i <= 21; i++)
        {
            m_boxOriginPositions[i] = m_boxOriginTransforms[i].transform.localPosition;
            m_boxOriginRotations[i] = m_boxOriginTransforms[i].transform.localRotation;
        }
	}

    void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "MinigameBox")
        {
            m_numberOfBoxes -= 1;
            //si toutes les boites sont tombées du stand, on reset leur position
            if (m_numberOfBoxes == 0)
            {
                StartCoroutine(StartCountdown());
            }
        }
    }

    private void Update()
    {
        //on permet au joueur de reset manuellement à partir d'un certain nombe de canettes tombées
        if (m_numberOfBoxes >= 10)
        {
            m_resetButton.SetActive(false);
        }
        else
        {
            m_resetButton.SetActive(true);
        }

        //affiche le nombre de boites restantes sur le stand
        if (m_numberOfBoxes >= 10)
        {
            m_scoreDisplay.text = "Nombre de boites restantes : " + m_numberOfBoxes;
        }
        else if (m_numberOfBoxes < 10 && m_numberOfBoxes > 0)
        {
            m_scoreDisplay.text = "Nombre de boites restantes : " + m_numberOfBoxes + "\nUtilisez le bouton pour recommencer.";
        }
        else
        {
            m_scoreDisplay.text = "\nLe jeu sera remis à zéro dans : \n" + currCountdownValue + " secondes.";
        }

    }

    void Reset()
    {
        //on récupère les nouvelles positions des boites
        int j = 0;
        //on accède à chaque transform une par une pour la remplacer par l'ancienne transform
        foreach (Transform transform in m_boxOriginTransforms)
        {
            transform.localPosition = m_boxOriginPositions[j];
            //transform.localPosition = new Vector3(0f, 0f, 0f);
            transform.localRotation = m_boxOriginRotations[j];
            j += 1;
        }
    }

    float currCountdownValue;
    public IEnumerator StartCountdown(float countdownValue = 3)
    {
        currCountdownValue = countdownValue;
        while (currCountdownValue > 0)
        {
            Debug.Log("Countdown: " + currCountdownValue);
            yield return new WaitForSeconds(1.0f);
            currCountdownValue--;
        }
        Reset();
        m_numberOfBoxes = 21;
    }
}