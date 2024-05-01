using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

public class RandomCubesGenerator : MonoBehaviour
{
#if UNITY_EDITOR
    [Header("Root")]
    [SerializeField] private Transform _parent;

    [Header("Cubes")]
    [SerializeField] private Vector2 _plane = new Vector2(40, 40);
    [SerializeField] private Vector2 _range = new Vector2(2000, 2000);
    [SerializeField] private Vector2 _sectionSize = new Vector2(40, 40);
    [SerializeField] private float _floorHeight = -150f;
    [SerializeField] private Vector2 _heightRange = new Vector2(75, 125);
    [SerializeField] private Vector2 _skyscraperHeightRange = new Vector2(160, 320);
    [SerializeField, Range(0f, 1f)] private float _skyscraperChance = 0.05f;

    [Header("Material")]
    [SerializeField] private Material _material;

    [Header("Static Settings")]
    [SerializeField]
    private StaticEditorFlags _staticEditorFlags =
        // StaticEditorFlags.ContributeGI |
        StaticEditorFlags.OccluderStatic |
        StaticEditorFlags.OccludeeStatic |
        StaticEditorFlags.BatchingStatic |
        StaticEditorFlags.ReflectionProbeStatic |
        StaticEditorFlags.OffMeshLinkGeneration |
        StaticEditorFlags.NavigationStatic;
    [SerializeField] private ReceiveGI _receiveGI = ReceiveGI.LightProbes;


    [ContextMenu(nameof(GenerateCubes))]
    public void GenerateCubes()
    {
        // Clear all children
        for (int i = _parent.childCount - 1; i >= 0; i--)
        {
            DestroyImmediate(_parent.GetChild(i).gameObject);
        }

        // Add Plane
        GameObject plane = GameObject.CreatePrimitive(PrimitiveType.Plane);
        plane.transform.SetParent(_parent);
        plane.transform.localScale = new Vector3(_range.x, 1, _range.y) * 0.1f;
        plane.transform.position = new Vector3(0, _floorHeight, 0);
        GameObjectUtility.SetStaticEditorFlags(plane, _staticEditorFlags);
        MeshRenderer planeRenderer = plane.GetComponent<MeshRenderer>();
        planeRenderer.material = _material;
        planeRenderer.receiveGI = _receiveGI;

        // Add Cubes
        int xCount = Mathf.FloorToInt(_range.x / _sectionSize.x);
        int zCount = Mathf.FloorToInt(_range.y / _sectionSize.y);
        Vector2 startPoint = new Vector2(-_range.x * 0.5f, -_range.y * 0.5f);

        for (int z = 0; z < zCount; z++)
        {
            for (int x = 0; x < xCount; x++)
            {
                Vector2 gridPosition = new Vector2(
                    startPoint.x + x * _sectionSize.x,
                    startPoint.y + z * _sectionSize.y
                    );

                // skip if it's in plane
                if (gridPosition.x > -_plane.x * 0.5f && gridPosition.x < _plane.x * 0.5f &&
                    gridPosition.y > -_plane.y * 0.5f && gridPosition.y < _plane.y * 0.5f)
                {
                    continue;
                }

                bool isSkyScraper = Random.value < _skyscraperChance;
                float height = isSkyScraper ? Random.Range(_skyscraperHeightRange.x, _skyscraperHeightRange.y) : Random.Range(_heightRange.x, _heightRange.y);
                Vector3 position = new Vector3(gridPosition.x, _floorHeight + height * 0.5f, gridPosition.y);

                Vector3 size = new Vector3(
                    Random.Range(_sectionSize.x * 0.2f, _sectionSize.x * 0.8f),
                    height,
                    Random.Range(_sectionSize.y * 0.2f, _sectionSize.y * 0.8f)
                    );

                GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                cube.transform.SetParent(_parent);
                cube.transform.position = position;
                cube.transform.localScale = size;
                GameObjectUtility.SetStaticEditorFlags(cube, _staticEditorFlags);
                MeshRenderer cubeRenderer = cube.GetComponent<MeshRenderer>();
                cubeRenderer.material = _material;
                cubeRenderer.receiveGI = _receiveGI;
            }
        }
    }
#endif
}
