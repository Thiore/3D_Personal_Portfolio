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

    public bool isBoss = false;
    private bool isTurn = false;

    private void Awake()
    {
        TryGetComponent(out Anim);

        if (GameManager.instance.isMotherDeath.Equals(true))
            pattern = Mother_Pattern.Death;
        else
            pattern = Mother_Pattern.Idle;

        player = GameObject.FindGameObjectWithTag("Player");
    }

    
   
    private void LateUpdate()
    {
        if(isBoss)
        {
            float angle = Vector3.SignedAngle(-Upper.forward, transform.position - player.transform.position,Vector3.up);
            Upper.eulerAngles += Vector3.up*angle;
        }
        if(Input.GetKey(KeyCode.Space))
        {
            float angle = Vector3.SignedAngle(Upper.forward, Base.forward, Vector3.up);
            Debug.Log(angle);
            if(Mathf.Abs(angle)>1f)
            {
                Upper.eulerAngles -= Vector3.up * angle*Time.deltaTime*5f;
            }
            
        }
    }

    public void OnBossStage()
    {
        isBoss = true;
    }

}
