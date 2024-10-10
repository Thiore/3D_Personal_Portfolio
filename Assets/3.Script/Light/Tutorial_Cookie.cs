using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tutorial_Cookie : MonoBehaviour
{
    [SerializeField] private RenderTexture LightCookie;
    [SerializeField] private Material CookieMat;

    [SerializeField] private float FirstSpeed;
    [SerializeField]  private float SecondSpeed;

    private float Cookie1_offset = 0f;
    private float Cookie2_offset = 0f;

    private void Awake()
    {
        if(FirstSpeed.Equals(0f))
            FirstSpeed = 0.25f;

        if (SecondSpeed.Equals(0f))
            SecondSpeed = 0.15f;
    }

    private void Update()
    {
        Cookie1_offset += FirstSpeed * Time.deltaTime;
        Cookie2_offset += SecondSpeed * Time.deltaTime;
        CookieMat.SetFloat("_Cookie1_offset", Cookie1_offset);
        CookieMat.SetFloat("_Cookie2_offset", Cookie2_offset);

        Graphics.Blit(LightCookie, LightCookie, CookieMat);
    }

}
