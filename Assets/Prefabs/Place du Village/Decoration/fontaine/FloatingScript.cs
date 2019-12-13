using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloatingScript : MonoBehaviour
{
   
    public float verticalSpeed;
    public float amplitude;
    [HideInInspector] public Vector3 tempPosition;

    void Start()
    {
        tempPosition = transform.position;
    }

    
    void Update()
    {
        
        tempPosition.y = Mathf.Sin(Time.realtimeSinceStartup * verticalSpeed) * amplitude;
        transform.position = tempPosition;

    }
}
