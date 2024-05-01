using UnityEngine;
using UnityEngine.UI;

public class FogControl : MonoBehaviour
{
    [SerializeField] private Button _buttonNoFog;
    [SerializeField] private Button _buttonUnityFog;
    [SerializeField] private Button _buttonCustomFog;
    [SerializeField] private Material _material;

    private void Awake()
    {
        _buttonNoFog.onClick.AddListener(OnButtonClickNoFog);
        _buttonUnityFog.onClick.AddListener(OnButtonClickUnityFog);
        _buttonCustomFog.onClick.AddListener(OnButtonClickCustomFog);
    }

    private void OnDestroy()
    {
        _buttonNoFog.onClick.RemoveListener(OnButtonClickNoFog);
        _buttonUnityFog.onClick.RemoveListener(OnButtonClickUnityFog);
        _buttonCustomFog.onClick.RemoveListener(OnButtonClickCustomFog);
    }

    private void OnButtonClickNoFog()
    {
        _material.EnableKeyword("_FOGMODE_OFF");
        _material.DisableKeyword("_FOGMODE_UNITY");
        _material.DisableKeyword("_FOGMODE_CUSTOM");
    }

    private void OnButtonClickUnityFog()
    {
        _material.DisableKeyword("_FOGMODE_OFF");
        _material.EnableKeyword("_FOGMODE_UNITY");
        _material.DisableKeyword("_FOGMODE_CUSTOM");
    }

    private void OnButtonClickCustomFog()
    {
        _material.DisableKeyword("_FOGMODE_OFF");
        _material.DisableKeyword("_FOGMODE_UNITY");
        _material.EnableKeyword("_FOGMODE_CUSTOM");
    }
}
