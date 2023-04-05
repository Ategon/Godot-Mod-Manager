extends Node

var Data = {}

var FileFunctions = {
  "info.txt": _readInfo,
  "changelog.txt": _readChangelog,
  "commands.gd": _readCommands,
  "*.wav": _readWav,
  "*.png": _readPng,
  "*.gd": _readGd,
  "*.txt": _readTxt,
}

func _readChangelog(path):
  var entry = {"key": "Changelog"}
  var data = _getNewlineFile(path)
  
  var i = -1
  var splitData = []
  for line in data:
    if(line.begins_with("---")):
      i += 1
      splitData.push_back([])
    else:
      splitData[i].push_back(line)
    
  for dataLine in splitData:  
    var localEntry = _readEntry(dataLine)
    if(!localEntry.has("Version")): continue
    entry[localEntry.Version] = localEntry
  return entry
  
## Given an unparsed input entry of an array of strings, convert it to an object
## using the parsing algorithm
func _readEntry(input: PackedStringArray):
  var entry = {}
  var indentationLevels: PackedStringArray = []
  var currentIndentation: int = 0
  
  for line in input:
    var splitLine: PackedStringArray = line.strip_edges().split(":")
    var actualIndentation: int = _countIndentation(line)
    
    if (actualIndentation < currentIndentation):
      currentIndentation = actualIndentation
      indentationLevels = indentationLevels.slice(0, currentIndentation)
    elif (currentIndentation < actualIndentation):
      # throw error
      pass
    
    match splitLine.size():
      1:
        if(splitLine[0].ends_with("[]")):
          
          var i = 0
          var position = entry
          while(i < actualIndentation - 1):
            if(position and position.has(indentationLevels[i])):
              position = position.get(indentationLevels[i])
              i += 1
            else:
              #error
              break
          
          if(indentationLevels.size() > 0 and !position.has(indentationLevels[i])):
            position[indentationLevels[i]] = {}
          
          
          var lineName = splitLine[0].substr(0, splitLine[0].length() - 2)
          indentationLevels.push_back(lineName)
          currentIndentation += 1
        elif(splitLine[0].begins_with("-")):
          var i = 0
          var position = entry

          while(i < actualIndentation - 1):
            position = position.get(indentationLevels[i])
            i += 1
            
          if(!position.has(indentationLevels[i])):
            position[indentationLevels[i]] = []
          position = position.get(indentationLevels[i])
          
          position.push_back(splitLine[0].substr(2))
        else:
          var i = 0
          var position = entry

          while(i < actualIndentation - 1):
            position = position.get(indentationLevels[i])
            i += 1
            
          if(!position.has(indentationLevels[i])):
            position[indentationLevels[i]] = []
          i += 1
          position = position.get(indentationLevels[i])
          
          position.Values.push_back(splitLine[0])
      2:
        var i = 0
        var position = entry
        
        while(i < actualIndentation - 1):
          position = position.get(indentationLevels[i])
          i += 1
        
        if(indentationLevels.size() > 0):
          if(!position.has(indentationLevels[i])):
            position[indentationLevels[i]] = {}
          i += 1
          position = position.get(indentationLevels[i])
        
        position[splitLine[0]] = splitLine[1].strip_edges()
      _:
        # throw error
        pass
  return entry

## Read the contents of a file provided a path and then return the contents as
## an array of strings delimited by newlines
func _getNewlineFile(path: String) -> PackedStringArray:
  var file: FileAccess = FileAccess.open(path, FileAccess.READ)
  var content: String = file.get_as_text()
  return content.split("\n", false)

func _readChangelog2(path):
  var localData = { "key": "Changelog" }
  
  var file = FileAccess.open(path, FileAccess.READ)
  var content = file.get_as_text() 
  var splitContent = content.split("\n", false)
  
  var currentEntry = {}
  var currentEntryKey = ""
  
  var currentChanges = {}
  var currentChangesKey = "";
  
  for line in splitContent:
    if(line == "---"):
      if(currentChangesKey != ""):
        currentEntry[currentChangesKey] = currentChanges.text
        currentChangesKey = ""
      if(currentEntryKey):
        localData[currentEntryKey] = currentEntry
      currentEntry = {}
      currentEntryKey = ""
    else:
      var splitLine = line.split(":")
      if(currentChangesKey != ""):
        if(_countIndentation(splitLine[0]) < 2):
          currentEntry[currentChangesKey] = currentChanges.text
          currentChangesKey = ""
        else:
          if(splitLine.size() == 2):
            currentChanges[splitLine[0]] = splitLine[1]
            continue
          else:
            if(currentChanges.has("text")):
              currentChanges["text"] += splitLine[0].strip_edges() + "\n"
            else:
              currentChanges["text"] = splitLine[0].strip_edges() + "\n"
            continue
      
      if(splitLine.size() == 2):
        if(splitLine[0].strip_edges() == "Changes"):
          currentChangesKey = splitLine[0].strip_edges()
          currentChanges = {}
        else:
          currentEntry[splitLine[0]] = splitLine[1]
          if(splitLine[0] == "Version"):
            currentEntryKey = splitLine[1]
          
        
  
  if(currentEntryKey):
    localData[currentEntryKey] = currentEntry
  
  return localData

func _readInfo(path):
  var localData = { "key": "Info" }
  
  return localData

func _readGd(path):
  return load(path)

func _readPng(path):  
  return ImageTexture.create_from_image(Image.load_from_file(path))

func _readWav(filepath):
  var file = FileAccess.open(filepath, FileAccess.READ)

  var bytes = file.get_buffer(file.get_length())
  
  if filepath.ends_with(".wav"):
    var newstream = AudioStreamWAV.new()

    var bits_per_sample = 0
    
    for i in range(0, 100):
      var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
      
      if those4bytes == "RIFF": 
        print ("RIFF OK at bytes " + str(i) + "-" + str(i+3))
        #RIP bytes 4-7 integer for now
      if those4bytes == "WAVE": 
        print ("WAVE OK at bytes " + str(i) + "-" + str(i+3))

      if those4bytes == "fmt ":
        print ("fmt OK at bytes " + str(i) + "-" + str(i+3))
        
        #get format subchunk size, 4 bytes next to "fmt " are an int32
        var formatsubchunksize = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
        print ("Format subchunk size: " + str(formatsubchunksize))
        
        #using formatsubchunk index so it's easier to understand what's going on
        var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "

        #get format code [Bytes 0-1]
        var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
        var format_name
        if format_code == 0: format_name = "8_BITS"
        elif format_code == 1: format_name = "16_BITS"
        elif format_code == 2: format_name = "IMA_ADPCM"
        else: 
          format_name = "UNKNOWN (trying to interpret as 16_BITS)"
          format_code = 1
        print ("Format: " + str(format_code) + " " + format_name)
        #assign format to our AudioStreamSample
        newstream.format = format_code
        
        #get channel num [Bytes 2-3]
        var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
        print ("Number of channels: " + str(channel_num))
        #set our AudioStreamSample to stereo if needed
        if channel_num == 2: newstream.stereo = true
        
        #get sample rate [Bytes 4-7]
        var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
        print ("Sample rate: " + str(sample_rate))
        #set our AudioStreamSample mixrate
        newstream.mix_rate = sample_rate
        
        #get byte_rate [Bytes 8-11] because we can
        var byte_rate = bytes[fsc0+8] + (bytes[fsc0+9] << 8) + (bytes[fsc0+10] << 16) + (bytes[fsc0+11] << 24)
        print ("Byte rate: " + str(byte_rate))
        
        #same with bits*sample*channel [Bytes 12-13]
        var bits_sample_channel = bytes[fsc0+12] + (bytes[fsc0+13] << 8)
        print ("BitsPerSample * Channel / 8: " + str(bits_sample_channel))
        
        #aaaand bits per sample/bitrate [Bytes 14-15]
        bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
        print ("Bits per sample: " + str(bits_per_sample))
        
      if those4bytes == "data":
        assert(bits_per_sample != 0)
        
        var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
        print ("Audio data/stream size is " + str(audio_data_size) + " bytes")

        var data_entry_point = (i+8)
        print ("Audio data starts at byte " + str(data_entry_point))
        
        var data = bytes.slice(data_entry_point, data_entry_point+audio_data_size-1)
        
        if bits_per_sample in [24, 32]:
          print("??")
        else:
          newstream.data = data
      # end of parsing
      #---------------------------

    #get samples and set loop end
    var samplenum = newstream.data.size() / 4
    newstream.loop_end = samplenum
    newstream.loop_mode = 1 #change to 0 or delete this line if you don't want loop, also check out modes 2 and 3 in the docs
    return newstream  #:D
  else:
    print ("ERROR: Wrong filetype or format")
  file.close()


func _readCommands(path):
  var localData = { "key": "Commands" }
  
  localData["File"] = load(path)
  
  return localData

func _ready():
  read_mods()

func read_mods():
  Data = {}
  var dir = DirAccess.open("user://")
  if not dir.dir_exists("mods"):
    dir.make_dir("mods")
  
  
  var modData = _readDirectory("user://mods")
  var localData = _readDirectory("res://Parts")
  
  for data in localData:
    Data = _mergeObjects(localData[data], Data)
  
  for data in modData:
    Data = _mergeObjects(modData[data], Data)
  
  var nodes = GetAllTreeNodes()
  for node in nodes:
    if node.has_method("_reload"):
      node.callv("_reload", [])
  
func _mergeObjects(object1, object2):
  var newObject = {}
  for key in object1:
    newObject[key] = object1[key]
  for key in object2:
    if(newObject.has(key)):
      if(typeof(newObject[key]) == TYPE_STRING):
        newObject[key] = object1[key]
      elif(typeof(newObject[key]) == TYPE_OBJECT):
        if newObject[key] is Texture:
          newObject[key] = object1[key]
        else:
          newObject[key] = _mergeObjects(object1[key], object2[key])
      elif(typeof(newObject[key]) == TYPE_DICTIONARY):
        newObject[key] = _mergeObjects(object1[key], object2[key])
      elif(typeof(newObject[key]) == TYPE_ARRAY):
        newObject[key] = object1[key] + object2[key]
    else:
      newObject[key] = object2[key]
  return newObject

func _readDirectory(path):
  var dir = DirAccess.open(path)
  var localData = {}
  
  if not dir:
    print("An error occurred when trying to access the path.")
    return
  
  dir.list_dir_begin()
  var file_name = dir.get_next()
  while file_name != "":
    if dir.current_is_dir():
      var microData = _readDirectory("%s/%s" % [path, file_name])
      if microData:
        localData[file_name] = microData
    else:
      var fileHandling = getFileHandling(file_name)
      
      if (fileHandling):
        var microData = fileHandling.call("%s/%s" % [path, file_name])
        if microData:
          localData[file_name.split(".")[0]] = microData  
    
    file_name = dir.get_next()
  
  return localData

func getFileHandling(file):
  var splitFile = file.split(".")
  
  for fileFunction in FileFunctions:
    if(fileFunction == file):
      return FileFunctions[fileFunction]
    
    var splitFileFunction = fileFunction.split(".")
    
    if (splitFile.size() == 3): continue # TEMP, SKIPS png.import
    
    if(splitFileFunction[0] == "*" and splitFileFunction[1] == splitFile[1]):
      return FileFunctions[fileFunction]
    
  return null

func _countIndentation(string: String):
  var spaces = 0
  
  for character in string:
    if(character == " "):
      spaces += 1
    else:
      return floor(spaces / 2)
  
  return spaces #temp?  

func _readTxt(path):
  var file = FileAccess.open(path, FileAccess.READ)
  var content = file.get_as_text()
  var localData = {}
  
  var splitContent = content.split("\n", false)
  
  var indentation = 0
  var indentationLevels = []
  
  for contentPiece in splitContent:
    var actualIndentation = _countIndentation(contentPiece)
    while(actualIndentation < indentation):
      indentation -= 1
      indentationLevels.pop_back()
    if(contentPiece.ends_with("[]")):
      var microData = localData
      var i = 0
      while i < indentation:
        microData = microData[indentationLevels[i]]
        i += 1
      
      indentation += 1
      indentationLevels.append(contentPiece.trim_suffix("[]"))
      microData[contentPiece.trim_suffix("[]")] = {}
    else:
      var splitArgs = contentPiece.split(":")
      if(splitArgs.size() == 2):
        var microData = localData
        var i = 0
        while i < indentation:
          microData = microData[indentationLevels[i]]
          i += 1
        microData[splitArgs[0].strip_edges()] = splitArgs[1].strip_edges()
      elif splitArgs.size() == 1:
        var microData = localData
        var i = 0
        while i < indentation - 1:
          microData = microData[indentationLevels[i]]
          i += 1
        if indentationLevels.size() == 0: continue
        if typeof(microData[indentationLevels[indentationLevels.size()-1]]) == TYPE_DICTIONARY:
          if microData[indentationLevels[indentationLevels.size()-1]].keys().size() == 0:
            microData[indentationLevels[indentationLevels.size()-1]] = [splitArgs[0].strip_edges()]
        else:
          microData[indentationLevels[indentationLevels.size()-1]] += [splitArgs[0].strip_edges()]
        #microData[splitArgs[0].strip_edges()] = splitArgs[0].strip_edges()
  
  return localData


func GetAllTreeNodes(node = get_tree().root, listOfAllNodesInTree = []):
    listOfAllNodesInTree.append(node)
    for childNode in node.get_children():
        GetAllTreeNodes(childNode, listOfAllNodesInTree)
    return listOfAllNodesInTree
