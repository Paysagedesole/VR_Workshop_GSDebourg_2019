using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoleSpawn : MonoBehaviour
{
    public GameObject m_startButton;
    public GameObject m_mole;
    [HideInInspector] public int m_moleScore = 0;

    private GameObject m_spawnPointsGameObject;
    private Component[] m_moleSpawners;
    private Vector3[] m_moleSpawnersPosition;
    private Transform m_moleSupport;
    private GameObject m_moleClone;

    public void Initialize()
    {
        m_moleSpawnersPosition = new Vector3[10];
        //on récupère le 3eme enfant de l'objet
        m_spawnPointsGameObject = this.gameObject.transform.GetChild(2).gameObject;
        m_moleSupport = this.transform;
        m_moleSpawners = m_spawnPointsGameObject.GetComponentsInChildren(typeof(Transform));
        for(int i = 0; i < 10; i++)
        {
            m_moleSpawnersPosition[i] = m_moleSpawners[i].transform.position;
        }
        StartCoroutine(GameCountdown());
	}
	
    public void MoleSpawner()
    {
        Destroy(m_moleClone);
        int j = Random.Range(1, 9);
        m_moleClone = Instantiate(m_mole, m_moleSpawnersPosition[j], Quaternion.identity);
    }

    float currCountdownValue;
    public IEnumerator GameCountdown(float countdownValue = 15)
    {
        currCountdownValue = countdownValue;
        InvokeRepeating("MoleSpawner", 1f, 0.85f);
        while (currCountdownValue > 0)
        {
            Debug.Log("Countdown: " + currCountdownValue);
            yield return new WaitForSeconds(1.0f);
            currCountdownValue--;
            m_startButton.SetActive(false);
        }
        MoleScore.m_moleScore = 0;
        StopAllCoroutines();
        CancelInvoke("MoleSpawner");
        m_startButton.SetActive(true);
    }
}
