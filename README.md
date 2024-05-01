# Custom Fog
![custom-fog-pan](https://github.com/wonkee-kim/unity-custom-fog/assets/830808/a4949392-9ac9-4775-b365-fbc19d8db4b4)<br>


<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/8e6363ee-0666-4cfc-ad11-4ebd8e1223c6" width="49%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/c800f7ee-554f-49ad-ae01-858e978b2d47" width="49%"><br>
<sup>(Left: Unity, Right: Custom)</sup><br>

<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/89d36cdb-55d0-49a9-9fab-4b9a463ba9d2" width="49%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/26c7a789-faa7-4146-9ea1-070b8d73c3c8" width="49%"><br>
<sup>(Left: Unity, Right: Custom)</sup><br>


## Demo (Available on Web, Mobile and MetaQuest - Powered by [Spatial Creator Toolkit](https://www.spatial.io/toolkit))
https://www.spatial.io/s/Custom-Fog-6631990c7e7b2cffbf4b4cb7



## Issues with Unity Fog
Unity's fog has a single color, making it difficult for it to appear natural from all angles when there are various colors scattered in the background. <br>
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/5bec652e-42ee-4ab1-9e2a-f09b91997bf9" width="49%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/6c7f7af2-c5bf-4c52-af70-66b2f53fedd6" width="49%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/e1129cfe-5a48-4913-801a-b091af50a04b" width="24%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/720e1466-07b6-4579-9fec-b7fccde44dc8" width="24%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/2105f432-7060-4931-bfff-55e9c6dbf5ec" width="24%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/3bce161a-6cd8-4f93-99e1-70735dadc64d" width="24%">

However, this custom fog addresses this by utilizing the skybox to seamlessly blend across all directions.
![custom-fog-pan](https://github.com/wonkee-kim/unity-custom-fog/assets/830808/a4949392-9ac9-4775-b365-fbc19d8db4b4)


## Features
### Fog color
Get fog color by sampling skybox. Use lower LOD to blur it out. <br>
[<sub>CustomFog.shader#L126</sub>](https://github.com/wonkee-kim/unity-custom-fog/blob/main/unity-custom-fog-unity/Assets/CustomFog/CustomFog/CustomFog.shader#L126)
```hlsl
half3 fogColor = SAMPLE_TEXTURECUBE_LOD(_FogTex, sampler_FogTex, -viewDirWS, _FogTexBlur).rgb;
```


### Height fog
[<sub>CustomFog.shader#L133-L134</sub>](https://github.com/wonkee-kim/unity-custom-fog/blob/main/unity-custom-fog-unity/Assets/CustomFog/CustomFog/CustomFog.shader#L133-L134)
```hlsl
half fogHeightIntensity = smoothstep(_FogHeightRange.x, _FogHeightRange.y, positionWS.y);
fogHeightIntensity = fogHeightIntensity * fogHeightIntensity; // Exponential
```

### Noise
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/155efee6-18d9-4080-86d3-5d38692e74a5" width="75%">


## Utilization
This method is applied to a game [Neon Ghost](https://www.spatial.io/s/Neon-Ghost-65e2209a07789d42d8a8c56c) on [Spatial](https://www.spatial.io/)<br>
The game is available on web, mobile and Meta Quest.<br>
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/3ae8d3e8-83da-4be6-8674-1a33e800aa1a" width="49%">
<img src ="https://github.com/wonkee-kim/unity-custom-fog/assets/830808/1f955b73-6e57-4bc8-8f6b-b160057994d6" width="49%">

