-- local aspectRatio = display.pixelHeight / display.pixelWidth

-- application = {
--    content = {
--       width = aspectRatio > 1.5 and 320 or math.ceil( 480 / aspectRatio ),
--       height = aspectRatio < 1.5 and 480 or math.ceil( 320 * aspectRatio ),
--       scale = "letterBox",
--       fps = 30,

--       imageSuffix = {
--          ["@2x"] = 1.5,
--          ["@4x"] = 3.0,
--       },
--    },
-- }
-- ipad1 ipad2 ipad3 ipadair ipadpro
if string.sub(system.getInfo("model"),1,4) == "iPad" then
    application = 
    {
        content =
        {
            width = 360,
            height = 480,
            scale = "letterBox",
            audioPlayFrequency = 22050,
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 960 and display.pixelHeight<1300 then
    application = 
    {
        content =
        {
            width = 320,
            height = 568,
            scale = "letterBox",
            audioPlayFrequency = 22050,
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" and display.pixelHeight > 1300 then
    application = 
    {
        content =
        {
            width = 750,
            height = 1334,
            scale = "letterBox",
            audioPlayFrequency = 22050,
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }

elseif string.sub(system.getInfo("model"),1,2) == "iP" then
    application = 
    {
        content =
        {
            width = 320,
            height = 480,
            scale = "letterBox",
            audioPlayFrequency = 22050,
            xAlign = "center",
            yAlign = "center",
            imageSuffix = 
            {
                ["@2x"] = 1.5,
                ["@4x"] = 3.0,
            },
        },
        notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
    }
elseif ( display.pixelHeight / display.pixelWidth > 1.72 ) then
   application =
   {
      content =
      {
         width = 320,
         height = 570,
         scale = "letterBox",
         audioPlayFrequency = 22050,
         xAlign = "center",
         yAlign = "center",
         imageSuffix =
         {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
         },
      },
      notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
   }
 
else
   application =
   {
      content =
      {
         width = 320,
         height = 512,
         scale = "letterBox",
         audioPlayFrequency = 22050,
         xAlign = "center",
         yAlign = "center",
         imageSuffix =
         {
            ["@2x"] = 1.5,
            ["@4x"] = 3.0,
         },
      },
      notification = 
        {
            iphone = {
                types = {
                    "badge", "sound", "alert"
                }
            }
        }
   }
end
