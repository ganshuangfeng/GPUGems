using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenerateMesh : MonoBehaviour
{
    [Range(10, 1000)]
    public int row = 10;
    [Range(10, 1000)]
    public int column = 10;
    public float unitWidth = 1;
    public float unitHeight = 1;
    // Start is called before the first frame update
    void Start()
    {
        Mesh mesh = new Mesh();
        Vector3[] v3s = new Vector3[row * column];
        Vector2 offset = new Vector2((row - 1) * unitWidth / 2, (column - 1) * unitHeight / 2);
        for(int i = 0; i < row; i++){
            for(int j = 0; j < column; j++){
                v3s[i + j * column] = new Vector3(i * unitWidth - offset.x, 0, j * unitHeight - offset.y);
            }
        }
        mesh.vertices = v3s;

        int[] index = new int[row * column * 6];
        int count = 0;
        for(int i = 0; i < row - 1; i++){
            for(int j =0; j < column - 1; j++){
                index[count] = i + j * column;
                index[count + 1] = i + (j + 1) * column;
                index[count + 2] = (i + 1) + (j + 1) * column;

                index[count + 3] = i + j * column;
                index[count + 4] = (i + 1) + (j + 1) * column;
                index[count + 5] = (i + 1) + j * column;

                count += 6;
            }
        }
        mesh.triangles = index;
        mesh.RecalculateNormals();

        Vector2[] uvs = new Vector2[row * column];
        for(int i = 0; i < row; i++){
            for(int j = 0; j < column; j++){
                uvs[i + j * column] = new Vector3(i % 2, j % 2);
            }
        }
        mesh.uv = uvs;

        MeshFilter meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh = mesh;
    }
}
