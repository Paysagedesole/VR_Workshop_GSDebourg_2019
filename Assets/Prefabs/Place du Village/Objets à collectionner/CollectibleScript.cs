using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollectibleScript : MonoBehaviour
{

    public int m_collectibleCounter = 0;
    void OnTriggerEnter(Collider other)
    {
        if (other.tag.Equals("CollectibleKey"))
        {
            m_collectibleCounter += 1;
            print(m_collectibleCounter);
        }
    }
}
