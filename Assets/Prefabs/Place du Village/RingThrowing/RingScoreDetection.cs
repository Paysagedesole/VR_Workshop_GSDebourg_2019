using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RingScoreDetection : MonoBehaviour 
{
    [HideInInspector] public int m_score = 0;
    public TextMesh m_scoreText;
    public AudioSource m_scoreSound;
    
    public void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "RingMesh" && other.isTrigger == true)
        {
            m_scoreSound.Play();
            print(m_score);
            m_score += 1;
            m_scoreText.text = "Score : " + m_score + "\n\n";
        }
    }
}
