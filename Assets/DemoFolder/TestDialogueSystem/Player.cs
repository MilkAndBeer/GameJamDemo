using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    public float HP { set; get; }
    public float Strength { set; get; }
    public float Luck { set; get; }

    public void AddHP(float num)
    {
        HP += num;
    }

    public void AddStrength(float num) 
    {
        Strength += num;
    }

    public void AddLuck(float num)
    {
        Strength += num;
    }


    void Start()
    {
        
    }

    void Update()
    {
        
    }
}
