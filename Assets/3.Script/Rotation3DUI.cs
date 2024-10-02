using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Rotation3DUI : MonoBehaviour
{

    [SerializeField] private Transform Sword;
    [SerializeField] private Transform Hammer;
    [SerializeField] private Transform Dagger;
    [SerializeField] private Transform GrateSword;
    [SerializeField] private Transform Umbrella;
    private bool isSword = false;
    private bool isHammer = false;
    private bool isDagger = false;
    private bool isGrateSword = false;
    private bool isUmbrella = false;
    private readonly Vector3 NormalScale = new Vector3(1f, 1f, 1f);

    private Animator UmbrellaAnim;

    private void Awake()
    {
        Umbrella.GetChild(0).TryGetComponent(out UmbrellaAnim);
    }

    private void Update()
    {
        if(gameObject.activeInHierarchy)
        {
            SwordTurn();
            HammerTurn();
            DaggerTurn();
            GrateSwordTurn();
            UmbrellaTurn();
        }
        
    }
    private void SwordTurn()
    {
        if (isSword)
        {
            if(Sword.localScale.Equals(NormalScale))
                Sword.localScale *= 1.5f;
            Sword.Rotate(Vector3.up, Time.unscaledDeltaTime * 20f);
        }
        else
        {
            if(!Sword.localScale.Equals(NormalScale))
            {
                Sword.localScale = NormalScale;
                Sword.localRotation = Quaternion.Euler(0f,0f,0f);
            }
            
        }
    }
    private void HammerTurn()
    {
        if (isHammer)
        {
            if (Hammer.localScale.Equals(NormalScale))
                Hammer.localScale *= 1.5f;
            Hammer.Rotate(Vector3.up, Time.unscaledDeltaTime * 20f);
        }
        else
        {
            if (!Hammer.localScale.Equals(NormalScale))
            {
                Hammer.localScale = NormalScale;
                Hammer.localRotation = Quaternion.Euler(0f, 0f, 0f);
            }
        }
    }
    private void DaggerTurn()
    {
        if (isDagger)
        {
            if(Dagger.localScale.Equals(NormalScale))
                Dagger.localScale *= 1.5f;
            Dagger.Rotate(Vector3.up, Time.unscaledDeltaTime * 20f);
        }
        else
        {
            if (!Dagger.localScale.Equals(NormalScale))
            {
                Dagger.localScale = NormalScale;
                Dagger.localRotation = Quaternion.Euler(0f, 0f, 0f);
            }
        }
    }
    private void GrateSwordTurn()
    {
        if (isGrateSword)
        {
            if (GrateSword.localScale.Equals(NormalScale))
                GrateSword.localScale *= 1.5f;
            GrateSword.Rotate(Vector3.up, Time.unscaledDeltaTime * 20f);
        }
        else
        {
            if (!GrateSword.localScale.Equals(NormalScale))
            {
                GrateSword.localScale = NormalScale;
                GrateSword.localRotation = Quaternion.Euler(0f, 0f, 0f);
            }
        }
    }
    private void UmbrellaTurn()
    {
        if (isUmbrella)
        {
            if (Umbrella.localScale.Equals(NormalScale))
            {
                UmbrellaAnim.SetTrigger("open");
                Umbrella.localScale *= 1.5f;
                
            }
                
            Umbrella.Rotate(Vector3.up, Time.unscaledDeltaTime * 20f);
        }
        else
        {
            if (!Umbrella.localScale.Equals(NormalScale))
            {
                UmbrellaAnim.SetTrigger("close");
                Umbrella.localScale = NormalScale;
                Umbrella.localRotation = Quaternion.Euler(0f, 0f, 0f);
                
            }
        }
    }

    public void isSwordTurn()
    {
        isSword = !isSword;
    }
    public void isHammerTurn()
    {
        isHammer = !isHammer;
    }
    public void isDaggerTurn()
    {
        isDagger = !isDagger;
    }
    public void isGrateSwordTurn()
    {
        isGrateSword = !isGrateSword;
    }
    public void isUmbrellaTurn()
    {
        isUmbrella = !isUmbrella;
    }
}
