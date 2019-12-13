using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingTargetScript : MonoBehaviour
{
   
    public float verticalSpeed;
    public float horizontalSpeed;
    public float amplitude;
    [HideInInspector] public Vector3 tempPosition;
    [HideInInspector] public Vector3 originPosition;

    void Start()
    {
        originPosition = transform.position;
        tempPosition = transform.position;
    }

    
    void Update()
    {
        
        tempPosition.y = originPosition.y + Mathf.Sin(Time.realtimeSinceStartup * verticalSpeed) * amplitude;
        tempPosition.x = originPosition.x + Mathf.Sin(Time.realtimeSinceStartup * horizontalSpeed) * amplitude;
        transform.position = tempPosition;

    }
}
