using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class Boss_MotherForest : MonoBehaviour
{
    private enum Mother_Pattern
    {
        Idle = 0,
        Slam_BRFL,
        Slam_BLFR,
        Spin,
        Spin_Slow,
        Lift,
        Lift_DmgR,
        Lift_DmgL,
        Fall,
        Death
    }

    private Mother_Pattern pattern;

    [SerializeField] private Transform Upper;
    [SerializeField] private Transform Base;
    [SerializeField] private Animator[] Leaf;

    private Animator Anim;

    private GameObject player = null;
    private Transform LastUpper;
    private Transform LastBase;

    public bool isBoss;
    private bool isTurn = false;

    private void Awake()
    {
        TryGetComponent(out Anim);

        if (GameManager.instance.isMotherDeath.Equals(true))
            pattern = Mother_Pattern.Death;
        else
            pattern = Mother_Pattern.Idle;

        player = GameObject.FindGameObjectWithTag("Player");
        LastUpper = Upper;
        LastBase = Base;
        isBoss = true;
    }

    
   
    private void LateUpdate()
    {
        if(Input.GetKey(KeyCode.Return))
        {
            float angle = Vector3.SignedAngle(LastUpper.forward, player.transform.position - transform.position,Vector3.up);
            if(Mathf.Abs(angle)>5f)
            {
                Upper.eulerAngles += Vector3.up * angle;
            }
        }
        if(Input.GetKey(KeyCode.Space))
        {
            float angle = Vector3.SignedAngle(LastUpper.forward, -Base.forward, Vector3.up);
            Debug.Log(LastUpper.eulerAngles);
            if(Mathf.Abs(angle)>5f)
            {
                Upper.eulerAngles = LastUpper.eulerAngles + Vector3.up * angle*0.1f;
            }
            Debug.Log(Upper.eulerAngles);
            
        }
        
        LastUpper = Upper;
    }


}
