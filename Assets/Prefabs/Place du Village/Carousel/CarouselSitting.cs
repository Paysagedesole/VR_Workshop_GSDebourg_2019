using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarouselSitting : MonoBehaviour {

    public GameObject m_cameraRig;
    public GameObject m_originParent;
    public Vector3 m_entryPoint;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.name == "[VRTK][AUTOGEN][BodyColliderContainer]" && other.isTrigger == true)
        {
            m_entryPoint = m_cameraRig.transform.position;
            m_cameraRig.transform.parent = transform;
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.name == "[VRTK][AUTOGEN][BodyColliderContainer]" && other.isTrigger == true)
        {
            m_cameraRig.transform.parent = m_originParent.transform;
            m_cameraRig.transform.position = m_entryPoint;
        }
    }
}
