const { exec } = require("child_process");

function generateKundli(birthDate, birthTime, latitude, longitude, callback) {
    const pythonScript = "python3 kundli_calculator.py";
    const command = \\ \ \ \ \\;

    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(\xec error: \The term '.\Fix-AllReactEscapes.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again. The term '.\Fix-AllReactEscapes.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again. The term 'pnpm' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again. The term '.\Fix-ProgressBarWidth.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again. Exception calling "Join" with "2" argument(s): "Value cannot be null. (Parameter 'values')" The term '.\Setup-KundliMatchWeb.ps1' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.\);
            return callback(error, null);
        }
        if (stderr) {
            console.error(\stderr: \\);
            return callback(stderr, null);
        }
        callback(null, JSON.parse(stdout));
    });
}

module.exports = { generateKundli };
