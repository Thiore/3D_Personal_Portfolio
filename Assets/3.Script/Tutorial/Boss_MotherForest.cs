using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//보스 State Enum
public enum Mother_Pattern
{
    Idle = 0,
    Start,
    Slam_BRFL,
    Slam_BLFR,
    HyperSpin,
    SlamSpin,
    Lift,
    Death
}
public class Boss_MotherForest : MonoBehaviour
{
   

    //보스 애니메이터 파라미터 캐싱
    private readonly int a_Start = Animator.StringToHash("Start");
    private readonly int a_Death = Animator.StringToHash("Death");
    private readonly int a_LAttack = Animator.StringToHash("LATTACK");
    private readonly int a_RAttack = Animator.StringToHash("RATTACK");
    private readonly int a_SlamSpin = Animator.StringToHash("SlamSpin");
    private readonly int a_HyperSpin = Animator.StringToHash("HyperSpin");
    private readonly int a_Lift = Animator.StringToHash("Lift");
    private readonly int a_LLeg = Animator.StringToHash("LLeg");
    private readonly int a_RLeg = Animator.StringToHash("RLeg");
    private readonly int a_SpinEnd = Animator.StringToHash("SpinEnd");
    private readonly int a_ReadySpin = Animator.StringToHash("ReadySpin");


    private Mother_Pattern CurrentPattern;
    private Mother_Pattern LastPattern;

    [SerializeField] private Transform Upper;
    [SerializeField] private Transform Base;
    [SerializeField] private Animator[] Leaf;

    private Animator Anim;

    private GameObject player = null;
    private Vector3 LastUpper;

    private float LLeg;
    private float RLeg;


    public bool isBoss;
    private bool isTurn;

    private void Awake()
    {
        TryGetComponent(out Anim);

        if (GameManager.instance.isMotherDeath.Equals(true))
        {
            CurrentPattern = Mother_Pattern.Death;
        }
        else
            CurrentPattern = Mother_Pattern.Idle;

        LastPattern = CurrentPattern;

        player = GameObject.FindGameObjectWithTag("Player");
        LastUpper = Upper.eulerAngles;
        isBoss = false;
        isTurn = true;
        LLeg = 0f;
        RLeg = 0f;
        
    }

    private void Update()
    {
        if(isBoss)
        {
            if (LastPattern.Equals(CurrentPattern))
            {
                OnAnimation(CurrentPattern);
            }
        }
        

    }



    private void LateUpdate()
    {
        if(isTurn)
        {
            Upper.eulerAngles = LastUpper;
            float angle = Vector3.SignedAngle(Upper.forward, player.transform.position - transform.position,Vector3.up);
            if (Mathf.Abs(angle) > 1f)
            {
                Upper.eulerAngles += Vector3.up * angle*Time.deltaTime*5f;
            }
            else
                Upper.eulerAngles = LastUpper;
        }
        else
        {
            float angle = Upper.eulerAngles.y-LastUpper.y;
            if(Mathf.Abs(angle)>1f)
            {
                Upper.eulerAngles = LastUpper + Vector3.up * angle* Time.deltaTime*5f;
            }
            else
                Upper.eulerAngles = LastUpper;
            
            
        }
        LastUpper = Upper.eulerAngles;
    }

    private void OnAnimation(Mother_Pattern pattern)
    {
        switch (pattern)
        {
            case Mother_Pattern.Idle:
                Anim.SetTrigger(a_ReadySpin);
                break;
            case Mother_Pattern.Start:
                Anim.SetTrigger(a_Start);
                break;
            case Mother_Pattern.Slam_BRFL:
                Anim.SetTrigger(a_RAttack);
                break;
            case Mother_Pattern.Slam_BLFR:
                Anim.SetTrigger(a_LAttack);
                break;
            case Mother_Pattern.HyperSpin:
                Anim.SetTrigger(a_HyperSpin);
                break;
            case Mother_Pattern.SlamSpin:
                Anim.SetTrigger(a_SlamSpin);
                break;
            case Mother_Pattern.Lift:
                Anim.SetTrigger(a_Lift);
                break;
            case Mother_Pattern.Death:
                Anim.SetTrigger(a_Death);
                break;
        }
    }

    //private IEnumerator Spin()
    //{

    //}
}