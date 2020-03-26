using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class CreateSinWave : MonoBehaviour
{
    public int WaveCount = 4;
    public float RefreshReq = 3;
    Material mat;
    private float currentPeak;
    private float currentDir;
    private float currentAmp;
    private float currentSpeed;

    private float targetPeak;
    private float targetDir;
    private float targetAmp;
    private float targetSpeed;

    private float lerpVal = 0; // 插值系数
    private Dictionary<string, Dictionary<string,float>> waveCurrentData = new Dictionary<string, Dictionary<string,float>>();
    private Dictionary<string, Dictionary<string,float>> waveTargetData = new Dictionary<string, Dictionary<string,float>>();
    // Start is called before the first frame update
    void Start()
    {
        mat = GetComponent<MeshRenderer>().material;
        waveCurrentData = GenerateRandomWave();
        waveTargetData = GenerateRandomWave();
        StartCoroutine(CreateWave());
    }

    IEnumerator CreateWave() {
        while (true) {
            yield return new WaitForSecondsRealtime(RefreshReq);
            lerpVal = 0;
            waveTargetData = GenerateRandomWave();
        }
    }

    void Update() {
        foreach(KeyValuePair<string, Dictionary<string, float>> val in waveCurrentData) {
            List<float> data = new List<float>();
            waveTargetData[val.Key] = LerpWave(val.Value, waveTargetData[val.Key], ref data);
            mat.SetFloatArray(val.Key, data.ToArray());
        }
        lerpVal += Time.deltaTime;
    }

    Dictionary<string, float> LerpWave(Dictionary<string, float> cur, Dictionary<string, float> target,ref List<float> data) {
        Dictionary<string, float> wavedata = new Dictionary<string, float>();
        foreach (KeyValuePair<string, float> val in cur) {
            float attrVal = Mathf.Lerp(val.Value, target[val.Key], lerpVal / RefreshReq);
            wavedata.Add(val.Key, attrVal);
            data.Add(attrVal);
        }
        return wavedata;
    }


    Dictionary<string, Dictionary<string, float>> GenerateRandomWave() {
        Dictionary<string, Dictionary<string, float>> waveData = new Dictionary<string, Dictionary<string, float>>();
        for (int i = 1; i < WaveCount + 1; i++)
        {
            string wave = "Wave" + i;
            Dictionary<string, float> data = new Dictionary<string, float>();
            float peak = Random.Range(0.3f, 0.4f);
            data.Add("peak", peak);
            float dir = Random.Range(0f, 1.0f);
            data.Add("dir", dir);
            float amp = Random.Range(10.0f, 12.0f);
            data.Add("amp", amp);
            float speed = Random.Range(3f, 8f);
            data.Add("speed", speed);
            waveData.Add(wave, data);
        }
        return waveData;
    }
   
}
