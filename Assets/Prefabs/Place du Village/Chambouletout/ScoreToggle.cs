using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScoreToggle : MonoBehaviour
{
    public TextMesh m_scoreDisplay;

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "[VRTK][AUTOGEN][BodyColliderContainer]" && other.isTrigger == true)
        {
            m_scoreDisplay.characterSize = 0.01f;
        }
    }
    void OnTriggerExit(Collider other)
    {
        if (other.gameObject.name == "[VRTK][AUTOGEN][BodyColliderContainer]" && other.isTrigger == true)
        {
            m_scoreDisplay.characterSize = 0f;
        }
    }
}
