using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoleScore : MonoBehaviour {
    [HideInInspector] public static int m_moleScore = 0;
    private int m_highScore = 0;
    public TextMesh m_moleScoreDisplay;

    private void Update()
    {
        m_moleScoreDisplay.text = "Score : " + m_moleScore + "\nHigh Score : " + m_highScore;
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "MoleMesh" && other.isTrigger == true)
        { 
            m_moleScore += 1;
            m_moleScoreDisplay.text = "Score : " + m_moleScore;
            if (m_moleScore > m_highScore)
            {
                m_highScore = m_moleScore;
            }
        }
    }
}
