extends CanvasLayer

var SCORE = 0;
var COINS = 0;
var VEGGIES = 0;

var scoreface = false;

var scores = [5000,10000,20000,50000,99999];
var sfx_playing = false;
var onek = false;
var fivek = false;
var onem = false;
var onefivem = false;

func _ready():
	$status.play("default");
	$coinstatus.play("default");
	$veggetables.play("default");

func _process(delta):
	$score.set_text("[wave amp=350 freq=2][center]" + str(SCORE));	
	if SCORE < scores[0]: onek = false;
	if SCORE < scores[1]: fivek = false;
	if SCORE < scores[2]: onem = false;
	if SCORE < scores[3]: onefivem = false;

	if SCORE >= scores[0] and SCORE < scores[1]:
		if not onek:
			scoreSetter(" [wave amp=500 freq=5][rainbow freq=1 sat=.6 val=1]NICE!", $score/'5000', "score");
		onek = true;
	elif SCORE >= scores[1] and SCORE < scores[2]:
		if not fivek:
			scoreSetter(" [shake rate=10.0 level=100][wave amp=350 freq=2][rainbow freq=1 sat=.6 val=1]GREAT!", $score/'10000', "score");
		fivek = true;
	elif SCORE >= scores[2] and SCORE < scores[3]:
		if not onem:
			scoreSetter(" [shake rate=20.0 level=200][rainbow freq=1 sat=.6 val=1]AMAZING!", $score/'20000', "score");
		onem = true;
	elif SCORE >= scores[3] and SCORE < scores[4]:
		if not onefivem:
			scoreSetter(" [shake rate=30.0 level=500][wave amp=500 freq=10][rainbow freq=2 sat=.6 val=1]DAMN!", $score/'50000', "dumbass");
		onefivem = true;
			
#x - what the text should be set to
#y - what sound should be played
#z - what face should be displayed
func scoreSetter(x: String, y, z: String): 
	scoreface = true;
	$pointcheer.set_text(x);
	$pointcheer.visible = true;
	$status.play(z);
	if not sfx_playing:
		sfx_playing = true;
		y.play();
		if SCORE >= scores[3] and SCORE < scores[4]:
			await get_tree().create_timer(.7).timeout;
			$score/giggle.play();
	await get_tree().create_timer(1.5).timeout;
	scoreface = false;
	$status.play("default");
	sfx_playing = false;
	$pointcheer.visible = false;
	$pointcheer.set_text(" null");
