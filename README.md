A new project I got into after a colleague challenged me to 'draw more graphs' in my awk one-liners<br>
<p>
Well, not really a graph, but it did sattisfy him to see some 3D models bouncing around a terminal.
<p>
It can draw 3D models in your terminal, using a model file in the 'models' folder.<br>
A model file understands four types of lines:<br>

- var &lt;key&gt; &lt;value&gt;
- col &lt;red&gt;;&lt;green&gt;;&ltblue&gt
- vert &lt;x-coord&gt; &lt;y-coord&gt; &lt;z-coord&gt;
- tri &lt;vertex1&gt; &lt;vertex2&gt; &lt;vertex3&gt; [&lt;color&gt;]

The 'var' keyword sets a value to a variable (key). This variable can then be used in the 'vert' and 'edge' definitions<br>
<p>
The 'col' keyword defines a 'color' the red, green and blue values range from 0 to 255<br>
<p>
The 'vert' keyword defines a 'vertex' (a point in 3D space) with an X, a Y and a Z coordinate<br>
<p>
The 'tri' keyword connects three vertices into a triangle (in a certain color)<br>
<p>
This is a first attempt to draw things in 3D space, so I hope to spend some more time refining everything<br>
<p>
Here's a screenshot:<br>
![](https://raw.githubusercontent.com/patsie75/awk-3d/master/icosahedron.png)

See youtube for a moving example: https://youtu.be/snj8Nl8pC6E or https://youtu.be/cNM4f10IZWQ
