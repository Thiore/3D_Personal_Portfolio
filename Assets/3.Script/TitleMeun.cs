using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public enum eTitle
{
    Start = 0,
    Option,
    Exit
}

public class TitleMeun : MonoBehaviour
{
    public eTitle title;

    private bool isPointer;

    [SerializeField] private GameObject StartMark;
    [SerializeField] private GameObject OptionMark;
    [SerializeField] private GameObject ExitMark;
    

    private void Start()
    {
        title = eTitle.Start;
        OnMark();
        isPointer = false;
    }

    private void Update()
    {
        
            if(Input.GetKeyDown(KeyCode.DownArrow))
            {
                if(!title.Equals(eTitle.Exit))
                {
                    title += 1;
                }
                else
                {
                    title = eTitle.Start;
                }
                OnMark();
            }
            if(Input.GetKeyDown(KeyCode.UpArrow))
            {
                if (!title.Equals(eTitle.Start))
                {
                    title -= 1;
                }
                else
                {
                    title = eTitle.Exit;
                }
                OnMark();
            }
        
    }

    public void ClickStart()
    {
        SceneManager.LoadScene("HallofDoor");
    }

    public void OnStart()
    {
        isPointer = true;
        title = eTitle.Start;
        OnMark();
    }

    public void OnOption()
    {
        isPointer = true;
        title = eTitle.Option;
        OnMark();
    }

    public void OnExit()
    {
        isPointer = true;
        title = eTitle.Exit;
        OnMark();
    }

    public void PointerExit()
    {
        isPointer = false;
    }

    private void OnMark()
    {
        switch (title)
        {
            case eTitle.Start:
                StartMark.SetActive(true);
                OptionMark.SetActive(false);
                ExitMark.SetActive(false);
                break;
            case eTitle.Option:
                StartMark.SetActive(false);
                OptionMark.SetActive(true);
                ExitMark.SetActive(false);
                break;
            case eTitle.Exit:
                StartMark.SetActive(false);
                OptionMark.SetActive(false);
                ExitMark.SetActive(true);
                break;
        }
    }

}
