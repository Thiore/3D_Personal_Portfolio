using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Arrow : MonoBehaviour
{
    [SerializeField] private Transform Bow;
    [SerializeField] private Transform RHand;

    private Vector3 LatePos;

    private void OnEnable()
    {
        transform.position = Bow.position;
        LatePos = RHand.localPosition;
    }

    private void Update()
    {
        Vector3 CurVelocity = LatePos - RHand.localPosition;
        LatePos = RHand.localPosition;
        transform.position += CurVelocity;
    }
}
