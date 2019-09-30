A new project I got into after a colleague challenged me to 'draw more graphs' in my awk one-liners<br>
<p>
Well, not really a graph, but it did sattisfy him to see some 3D models bouncing around a terminal.
<p>
It can draw 3D models in your terminal, using a model file in the 'models' folder.<br>
A model file understands three types of lines:<br>

- var &lt;key&gt; &lt;value&gt;
- vert &lt;x-coord&gt; &lt;y-coord&gt; &lt;z-coord&gt;
- edge &lt;from-vertex&gt; &lt;to-vertex&gt; &lt;color&gt;

The 'var' keyword sets a value to a variable (key). This variable can then be used in the 'vert' and 'edge' definitions<br>
<p>
The 'vert' keyword defines a 'vertex' (a point in 3D space) with an X, a Y and a Z coordinate<br>
<p>
The 'edge' keyword connects two vertices with a line (in a certain color)<br>
<p>
This is a first attempt to draw things in 3D space, so I hope to spend some more time refining everything<br>
<p>
Here's a screenshot:<br>
![screenshot](/screenshot.png)


