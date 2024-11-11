import QtQuick 2.0
import MuseScore 3.0

MuseScore {
   menuPath: "Plugins.Add Metronome Part"
   description: "Add metronome part"
   version: "0.3"
   requiresScore: true
   id: addMetronomePart
   property var beatPattern
   property var log
   Component.onCompleted : {
      if (mscoreMajorVersion >= 4) {
          addMetronomePart.title = "Add Metronome Part";
      }
   }   
   

function myLog(str) {
   if (log) 
      console.log(str)
} 

function getBeatPattern (num, simple) {
   var sp = beatPattern[num]
   if (sp ==  undefined || simple) {
      sp = [76]
      for (var i = 1; i<num; i++)
         sp.push(77)
   }
   return sp
}

function addBeat(c, pitchVal) {
   var cTick = c.tick
   c.addNote(pitchVal, false)
   return (c.tick <= cTick)
} 


   onRun: {
      curScore.startCmd()
      curScore.appendPart("wood-blocks")
      var idx = curScore.nstaves-1
      log = false
      // curScore.parts[idx].isMetro = true
   beatPattern = {
    "1": [76],
    "2": [76, 77],
    "3": [76, 77, 77],
    "4": [76, 77, 76, 77],
    "5": [76, 77, 77, 76, 77],
    "6": [76, 77, 77, 76, 77, 77],
    "9": [76, 77, 77, 76, 77, 77, 76, 77, 77],
    "12": [76, 77, 77, 76, 77, 77, 76, 77, 77, 76, 77, 77]
};

            
      var c = curScore.newCursor()
      c.rewind(0)
      var lastPos = c.tick
      c.staffIdx = idx
      c.voice = 0   
      var eos = false
      var mx = 1
      measureLoop: do {
         c.setDuration( 1, c.measure.timesigActual.denominator)
         var simple = ( c.measure.timesigActual.str != c.measure.timesigNominal.str )
         var pattern = getBeatPattern(c.measure.timesigActual.numerator, simple)
         myLog (mx + " N " + c.measure.timesigActual.numerator + " D "+ c.measure.timesigActual.denominator)
         var num = c.measure.timesigActual.numerator
         for (var i=0; i<num; i++ ) {
             myLog ("- " + (i + 1) + " t " + c.tick)
             eos = addBeat(c, pattern[i])
             if (eos) 
                 break measureLoop      
         }
                      mx++     
      } while (!eos)

      curScore.endCmd()
      return
      // ( typeof(quit)==='undefined' ? Qt.quit : quit )()
   }
}

