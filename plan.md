Starting point(DONE):

Player controlled character: an elongated capsule. WASD moves the capsule around the screen.

Simple spherical obstacle flies from bottom to top of the screen every 5 seconds.

If missile collides with the obstacles, 10 out of 50 hitpoints are deducted. If hitpoints reach zero, scene restarts.

Lets decide that UP will be Y axis, forward(to the right of the screen) will be X axis, Z axis will be always zero.

Lets try camera with orthographic projection.

==============================================

Adding UI(DONE):

Now we need to display player's current score and health in UI. It shouldn't be distracting, but visible at any time. UI shouldn't be interactable, and meters should update each frame. Source for player health is "hp" field of the player script. Source for current flown distance is "metersFlown" of the player script.
